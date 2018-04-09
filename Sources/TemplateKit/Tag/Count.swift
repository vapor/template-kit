/// Returns the number of items in the supplied array.
///
///     count(<array>)
///
/// Supports counting arrays or dictionaries (keys).
public final class Count: TagRenderer {
    /// Creates a new `Count` tag renderer.
    init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        /// Require 1 parameter.
        try tag.requireParameterCount(1)

        let res: TemplateData

        /// Switch on the first param.
        switch tag.parameters[0].storage {
        case .dictionary(let dict): res = .int(dict.values.count)
        case .array(let arr): res = .int(arr.count)
        default: res = .null
        }

        return Future.map(on: tag) { res }
    }
}

