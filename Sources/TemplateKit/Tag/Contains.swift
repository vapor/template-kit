/// Returns `true` if the supplied array contains a given item.
///
///     contains(<array>, <item>
///
public final class Contains: TagRenderer {
    /// Creates a new `Contains` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        /// Require two parameters.
        try tag.requireParameterCount(2)

        let res: TemplateData

        /// Convert first param to an array or return false.
        if let array = tag.parameters[0].array {
            /// Return `true` if the array contains the item.
            let compare = tag.parameters[1]
            res = .bool(array.contains(compare))
        } else {
            res = .bool(false)
        }

        return Future.map(on: tag) { res }
    }
}
