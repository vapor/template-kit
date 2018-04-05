import Foundation

internal final class TemplateDataKeyedEncoder<K>: KeyedEncodingContainerProtocol
    where K: CodingKey
{
    typealias Key = K

    var codingPath: [CodingKey]
    var context: TemplateDataContext

    init(codingPath: [CodingKey], context: TemplateDataContext) {
        self.codingPath = codingPath
        self.context = context
    }

    func superEncoder() -> Encoder {
        /// FIXME: what do we do here?
        fatalError("unimplemented: LeafKeyedEncoder.superEncoder at \(codingPath)")
    }

    func encodeNil(forKey key: K) throws {
        context.data.set(to: .null, at: codingPath + [key])
    }

    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type, forKey key: K
        ) -> KeyedEncodingContainer<NestedKey>
        where NestedKey : CodingKey
    {
        let container = TemplateDataKeyedEncoder<NestedKey>(codingPath: codingPath + [key], context: context)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return TemplateDataUnkeyedEncoder(codingPath: codingPath + [key], context: context)
    }

    func superEncoder(forKey key: K) -> Encoder {
        return _TemplateDataEncoder(context: context, codingPath: codingPath + [key])
    }

    func encode(_ value: Bool, forKey key: K) throws {
        context.data.set(to: .bool(value), at: codingPath + [key])
    }

    func encode(_ value: Double, forKey key: K) throws {
        context.data.set(to: .double(value), at: codingPath + [key])
    }

    func encode(_ value: Float, forKey key: K) throws {
        context.data.set(to: .double(.init(value)), at: codingPath + [key])
    }

    func encode(_ value: Int, forKey key: K) throws {
        context.data.set(to: .int(value), at: codingPath + [key])
    }

    func encode(_ value: String, forKey key: K) throws {
        context.data.set(to: .string(value), at: codingPath + [key])
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(context: context, codingPath: codingPath + [key])
        try value.encode(to: encoder)
    }
}



