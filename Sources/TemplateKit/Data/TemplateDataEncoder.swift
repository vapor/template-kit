/// Converts `Encodable` objects to `TemplateData`.
public final class TemplateDataEncoder {
    /// Create a new `TemplateDataEncoder`.
    public init() {}

    /// Encode an `Encodable` item to `TemplateData`.
    public func encode<E>(_ encodable: E, on worker: Worker) throws -> Future<TemplateData> where E: Encodable {
        if let representable = encodable as? TemplateDataRepresentable {
            // Shortcut if the argument is "trivially" representable as `TemplateData`.
            return worker.future(try representable.convertToTemplateData())
        }

        let encoder = _TemplateDataEncoder(eventLoop: worker.eventLoop)
        try encodable.encode(to: encoder)
        return encoder.resolve(on: worker)
    }
}

/// MARK: Private

/// Holds partially evaluated template data. This may still contain futures
/// that need to be resolved.
fileprivate protocol TemplateDataResolvable {
    func resolve(on worker: Worker) -> Future<TemplateData>
}

extension TemplateData: TemplateDataResolvable {
    func resolve(on worker: Worker) -> Future<TemplateData> {
        return worker.future(self)
    }
}

extension Future: TemplateDataResolvable where T == TemplateData {
    func resolve(on worker: Worker) -> Future<TemplateData> {
        return self
    }
}

fileprivate final class DictionaryStorage: TemplateDataResolvable {
    var data: [String: TemplateDataResolvable] = [:]

    func resolve(on worker: Worker) -> Future<TemplateData> {
        return self.data.map { (key, value) in
            value.resolve(on: worker).map { resolvedValue in (key, resolvedValue) }
            }.map(to: TemplateData.self, on: worker) { keyValuePairs in
                .dictionary(.init(uniqueKeysWithValues: keyValuePairs))
        }
    }
}

fileprivate final class _TemplateDataEncoder: Encoder, FutureEncoder, TemplateDataResolvable {
    let codingPath: [CodingKey]
    let eventLoop: EventLoop
    var userInfo: [CodingUserInfoKey: Any] {
        return [:]
    }

    var data: TemplateDataResolvable?

    init(eventLoop: EventLoop, codingPath: [CodingKey] = []) {
        self.eventLoop = eventLoop
        self.codingPath = codingPath
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let storage: DictionaryStorage
        if let dictionaryHolder = self.data as? DictionaryStorage {
            storage = dictionaryHolder
        } else {
            storage = DictionaryStorage()
            self.data = storage
        }
        // Using the same dictionary storage for multiple subsequent calls to `container(keyedBy:)` allows us to store
        // all of those calls' data to the same underlying dictionary in the end rather than discard all previously
        // written data. (See `testEncodeSuperCustomImplementation` for an example where this is relevant.)
        let container = _TemplateDataKeyedEncoder<Key>(codingPath: codingPath, writingTo: storage, eventLoop: eventLoop)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _TemplateDataUnkeyedEncoder(codingPath: codingPath, eventLoop: eventLoop)
        self.data = container
        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        let container = _TemplateDataSingleValueEncoder(codingPath: codingPath)
        self.data = container
        return container
    }

    func encodeFuture<E>(_ future: EventLoopFuture<E>) throws where E : Encodable {
        self.data = future.flatMap(to: TemplateData.self) { encodable in
            try TemplateDataEncoder().encode(encodable, on: self.eventLoop)
        }
    }

    func resolve(on worker: Worker) -> Future<TemplateData> {
        return (self.data ?? TemplateData.null).resolve(on: worker)
    }
}

fileprivate final class _TemplateDataSingleValueEncoder: SingleValueEncodingContainer, TemplateDataResolvable {
    let codingPath: [CodingKey]
    var data: TemplateData?

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    func encodeNil() throws {
        self.data = .null
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        guard let data = value as? TemplateDataRepresentable else {
            throw TemplateKitError(identifier: "templateData", reason: "`\(T.self)` does not conform to `TemplateDataRepresentable`.")
        }
        self.data = try data.convertToTemplateData()
    }

    func resolve(on worker: Worker) -> Future<TemplateData> {
        return (self.data ?? .null).resolve(on: worker)
    }
}

fileprivate final class _TemplateDataKeyedEncoder<K>: KeyedEncodingContainerProtocol, TemplateDataResolvable where K: CodingKey {
    typealias Key = K

    let codingPath: [CodingKey]
    let eventLoop: EventLoop
    let storage: DictionaryStorage

    init(codingPath: [CodingKey], writingTo storage: DictionaryStorage, eventLoop: EventLoop) {
        self.codingPath = codingPath
        self.eventLoop = eventLoop
        self.storage = storage
    }

    func superEncoder() -> Encoder {
        let encoder = _TemplateDataEncoder(eventLoop: eventLoop, codingPath: codingPath + [BasicKey("super")])
        self.storage.data["super"] = encoder
        return encoder
    }

    func encodeNil(forKey key: K) throws {
        self.storage.data[key.stringValue] = TemplateData.null
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        let container = _TemplateDataKeyedEncoder<NestedKey>(
            codingPath: codingPath + [key], writingTo: .init(), eventLoop: eventLoop)
        self.storage.data[key.stringValue] = container
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let container = _TemplateDataUnkeyedEncoder(codingPath: codingPath + [key], eventLoop: eventLoop)
        self.storage.data[key.stringValue] = container
        return container
    }

    func superEncoder(forKey key: K) -> Encoder {
        let encoder = _TemplateDataEncoder(eventLoop: eventLoop, codingPath: codingPath + [key])
        self.storage.data[key.stringValue] = encoder
        return encoder
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        if let data = value as? TemplateDataRepresentable {
            self.storage.data[key.stringValue] = try data.convertToTemplateData()
        } else {
            let encoder = _TemplateDataEncoder(eventLoop: eventLoop, codingPath: codingPath + [key])
            try value.encode(to: encoder)
            self.storage.data[key.stringValue] = encoder
        }
    }

    func resolve(on worker: Worker) -> Future<TemplateData> {
        return self.storage.resolve(on: worker)
    }
}


fileprivate final class _TemplateDataUnkeyedEncoder: UnkeyedEncodingContainer, TemplateDataResolvable {
    let codingPath: [CodingKey]
    let eventLoop: EventLoop
    var data: [TemplateDataResolvable]

    var count: Int { return data.count }

    init(codingPath: [CodingKey], eventLoop: EventLoop) {
        self.codingPath = codingPath
        self.eventLoop = eventLoop
        self.data = []
    }

    func encodeNil() throws {
        self.data.append(TemplateData.null)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let container = _TemplateDataKeyedEncoder<NestedKey>(
            codingPath: codingPath, writingTo: .init(), eventLoop: eventLoop)
        self.data.append(container)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = _TemplateDataUnkeyedEncoder(codingPath: codingPath, eventLoop: eventLoop)
        self.data.append(container)
        return container
    }

    func superEncoder() -> Encoder {
        let encoder = _TemplateDataEncoder(eventLoop: eventLoop, codingPath: codingPath)
        self.data.append(encoder)
        return encoder
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(eventLoop: eventLoop, codingPath: codingPath)
        try value.encode(to: encoder)
        self.data.append(encoder)
    }

    func resolve(on worker: Worker) -> Future<TemplateData> {
        return self.data.map { value in
            value.resolve(on: worker)
            }.map(to: TemplateData.self, on: worker) { values in
                .array(values)
        }
    }
}
