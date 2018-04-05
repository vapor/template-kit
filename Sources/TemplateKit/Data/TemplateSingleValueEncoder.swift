import Core
import Foundation

internal final class TemplateDataSingleValueEncoder: SingleValueEncodingContainer {
    var codingPath: [CodingKey]
    var context: TemplateDataContext

    init(codingPath: [CodingKey], context: TemplateDataContext) {
        self.codingPath = codingPath
        self.context = context
    }

    func encodeNil() throws {
        context.data.set(to: .null, at: codingPath)
    }

    func encode(_ value: Bool) throws {
        context.data.set(to: .bool(value), at: codingPath)
    }

    func encode(_ value: Int) throws {
        context.data.set(to: .int(value), at: codingPath)
    }

    func encode(_ value: Double) throws {
        context.data.set(to: .double(value), at: codingPath)
    }

    func encode(_ value: Float) throws {
        context.data.set(to: .double(.init(value)), at: codingPath)
    }

    func encode(_ value: String) throws {
        context.data.set(to: .string(value), at: codingPath)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(context: context, codingPath: codingPath)
        try value.encode(to: encoder)
    }
}
