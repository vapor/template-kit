import Core

internal final class TemplateDataUnkeyedEncoder: UnkeyedEncodingContainer {
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
        let container = TemplateDataKeyedEncoder<NestedKey>(codingPath: codingPath + [index], context: context)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return TemplateDataUnkeyedEncoder(codingPath: codingPath + [index], context: context)
    }

    func superEncoder() -> Encoder {
        return _TemplateDataEncoder(context: context, codingPath: codingPath + [index])
    }

    func encode(_ value: Bool) throws {
        context.data.set(to: .bool(value), at: codingPath + [index])
    }

    func encode(_ value: Int) throws {
        context.data.set(to: .int(value), at: codingPath + [index])
    }

    func encode(_ value: Double) throws {
        context.data.set(to: .double(value), at: codingPath + [index])
    }

    func encode(_ value: String) throws {
        context.data.set(to: .string(value), at: codingPath + [index])
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(context: context, codingPath: codingPath + [index])
        try value.encode(to: encoder)
    }
}
