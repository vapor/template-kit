/// Converts `Encodable` objects to `TemplateData`.
public final class TemplateDataEncoder {
    /// Create a new `TemplateDataEncoder`.
    public init() {}

    /// Encode an `Encodable` item to `TemplateData`.
    public func encode<E>(_ encodable: E) throws -> TemplateData where E: Encodable {
        return try _encode(encodable)
    }

    /// Non-generic method.
    internal func _encode(_ encodable: Encodable) throws -> TemplateData {
        let encoder = _TemplateDataEncoder()
        try encodable.encode(to: encoder)
        return encoder.context.data
    }
}

/// MARK: Private

fileprivate final class _TemplateDataEncoder: Encoder, FutureEncoder {
    var codingPath: [CodingKey]
    var context: TemplateDataContext
    var userInfo: [CodingUserInfoKey: Any] {
        return [:]
    }

    init(context: TemplateDataContext = .init(data: .dictionary([:])), codingPath: [CodingKey] = []) {
        self.context = context
        self.codingPath = codingPath
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let keyed = _TemplateDataKeyedEncoder<Key>(codingPath: codingPath, context: context)
        return KeyedEncodingContainer(keyed)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _TemplateDataUnkeyedEncoder(codingPath: codingPath, context: context)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return _TemplateDataSingleValueEncoder(codingPath: codingPath, context: context)
    }

    func encodeFuture<E>(_ future: EventLoopFuture<E>) throws where E : Encodable {
        try context.data.set(to: future.convertToTemplateData(), at: codingPath)
    }
}

fileprivate final class _TemplateDataSingleValueEncoder: SingleValueEncodingContainer {
    var codingPath: [CodingKey]
    var context: TemplateDataContext

    init(codingPath: [CodingKey], context: TemplateDataContext) {
        self.codingPath = codingPath
        self.context = context
    }

    func encodeNil() throws {
        context.data.set(to: .null, at: codingPath)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        guard let data = value as? TemplateDataRepresentable else {
            throw TemplateKitError(identifier: "templateData", reason: "`\(T.self)` does not conform to `TemplateDataRepresentable`.")
        }
        try context.data.set(to: data.convertToTemplateData(), at: codingPath)
    }
}

fileprivate final class _TemplateDataKeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
    typealias Key = K

    var codingPath: [CodingKey]
    var context: TemplateDataContext

    init(codingPath: [CodingKey], context: TemplateDataContext) {
        self.codingPath = codingPath
        self.context = context
    }

    func superEncoder() -> Encoder {
        return _TemplateDataEncoder(context: context, codingPath: codingPath)
    }

    func encodeNil(forKey key: K) throws {
        context.data.set(to: .null, at: codingPath + [key])
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        let container = _TemplateDataKeyedEncoder<NestedKey>(codingPath: codingPath + [key], context: context)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return _TemplateDataUnkeyedEncoder(codingPath: codingPath + [key], context: context)
    }

    func superEncoder(forKey key: K) -> Encoder {
        return _TemplateDataEncoder(context: context, codingPath: codingPath + [key])
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(context: context, codingPath: codingPath + [key])
        try value.encode(to: encoder)
    }
}


fileprivate final class _TemplateDataUnkeyedEncoder: UnkeyedEncodingContainer {
    var count: Int
    var codingPath: [CodingKey]
    var context: TemplateDataContext

    var index: CodingKey {
        defer { count += 1 }
        return BasicKey(count)
    }

    init(codingPath: [CodingKey], context: TemplateDataContext) {
        self.codingPath = codingPath
        self.context = context
        self.count = 0
        context.data.set(to: .array([]), at: codingPath)
    }

    func encodeNil() throws {
        context.data.set(to: .null, at: codingPath + [index])
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let container = _TemplateDataKeyedEncoder<NestedKey>(codingPath: codingPath + [index], context: context)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return _TemplateDataUnkeyedEncoder(codingPath: codingPath + [index], context: context)
    }

    func superEncoder() -> Encoder {
        return _TemplateDataEncoder(context: context, codingPath: codingPath + [index])
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(context: context, codingPath: codingPath + [index])
        try value.encode(to: encoder)
    }
}

