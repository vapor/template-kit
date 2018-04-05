import Core

/// Converts encodable objects to TemplateData.
public final class TemplateDataEncoder {
    /// Create a new LeafEncoder.
    public init() {}

    /// Encode an encodable item to leaf data.
    public func encode(_ encodable: Encodable) throws -> TemplateData {
        let encoder = _TemplateDataEncoder()
        try encodable.encode(to: encoder)
        return encoder.context.data
    }
}

/// Internal leaf data encoder.
internal final class _TemplateDataEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]

    var context: TemplateDataContext

    init(context: TemplateDataContext = .init(data: .dictionary([:])), codingPath: [CodingKey] = []) {
        self.context = context
        self.codingPath = codingPath
        self.userInfo = [:]
    }

    /// See Encoder.container
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let keyed = TemplateDataKeyedEncoder<Key>(
            codingPath: codingPath,
            context: context
        )
        return KeyedEncodingContainer(keyed)
    }

    /// See Encoder.unkeyedContainer
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return TemplateDataUnkeyedEncoder(
            codingPath: codingPath,
            context: context
        )
    }

    /// See Encoder.singleValueContainer
    func singleValueContainer() -> SingleValueEncodingContainer {
        return TemplateDataSingleValueEncoder(
            codingPath: codingPath,
            context: context
        )
    }
}

/// MARK: Future

extension _TemplateDataEncoder: FutureEncoder {
    func encodeFuture<E>(_ future: Future<E>) throws {
        let future = future.map(to: TemplateData.self) { any in
            guard let encodable = any as? Encodable else {
                fatalError("The expectation (\(E.self)) provided to template encoder for rendering was not Encodable")
            }

            let encoder = _TemplateDataEncoder(
                context: self.context,
                codingPath: self.codingPath
            )
            try encodable.encode(to: encoder)
            return encoder.context.data
        }

        self.context.data.set(to: .future(future), at: codingPath)
    }
}

