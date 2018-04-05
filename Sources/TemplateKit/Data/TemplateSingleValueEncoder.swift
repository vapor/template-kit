import Core
import Foundation

internal final class TemplateDataSingleValueEncoder: SingleValueEncodingContainer {
    var codingPath: [CodingKey]
    var partialData: PartialTemplateData

    init(codingPath: [CodingKey], partialData: PartialTemplateData) {
        self.codingPath = codingPath
        self.partialData = partialData
    }

    func encodeNil() throws {
        partialData.data.set(to: .null, at: codingPath)
    }

    func encode(_ value: Bool) throws {
        partialData.data.set(to: .bool(value), at: codingPath)
    }

    func encode(_ value: Int) throws {
        partialData.data.set(to: .int(value), at: codingPath)
    }

    func encode(_ value: Double) throws {
        partialData.data.set(to: .double(value), at: codingPath)
    }

    func encode(_ value: Float) throws {
        partialData.data.set(to: .double(.init(value)), at: codingPath)
    }

    func encode(_ value: String) throws {
        partialData.data.set(to: .string(value), at: codingPath)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = _TemplateDataEncoder(partialData: partialData, codingPath: codingPath)
        try value.encode(to: encoder)
    }
}
