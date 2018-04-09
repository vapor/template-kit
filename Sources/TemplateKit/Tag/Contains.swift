/// Returns `true` if the supplied array contains a given item.
///
///     contains(<array>, <item>
///
public final class Contains: TagRenderer {
    /// Creates a new `Contains` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        /// Require two parameters.
        try parsed.requireParameterCount(2)

        /// Convert first param to an array or return false.
        guard let array = parsed.parameters[0].array  else {
            return .bool(false)
        }

        /// Return `true` if the array contains the item.
        let compare = parsed.parameters[1]
        return .bool(array.contains(compare))
    }
}
