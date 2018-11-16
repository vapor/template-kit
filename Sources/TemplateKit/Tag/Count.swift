/// Returns the number of items in the supplied array.
///
///     count(<array>)
///
/// Supports counting arrays or dictionaries (keys).
public final class Count: TagRenderer {
    /// Creates a new `Count` tag renderer.
    init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        /// Require 1 parameter.
        try tag.requireParameterCount(1)

        /// Switch on the first param.
        switch tag.parameters[0] {
        case .dictionary(let dict): return .int(dict.values.count)
        case .array(let arr): return .int(arr.count)
        default: return .null
        }
    }
}

