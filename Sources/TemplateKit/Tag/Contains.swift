/// Returns `true` if the supplied array contains a given item.
///
///     contains(<array>, <item>
///
public final class Contains: TagRenderer {
    /// Creates a new `Contains` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        /// Require two parameters.
        try tag.requireParameterCount(2)
        /// Convert first param to an array or return false.
        switch tag.parameters[0] {
        case .array(let array):
            /// Return `true` if the array contains the item.
            let compare = tag.parameters[1]
            return .bool(array.contains(compare))
        default:
            return .bool(false)
        }
    }
}
