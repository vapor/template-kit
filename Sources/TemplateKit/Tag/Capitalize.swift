/// Capitalizes a `String`-convertible item.
public final class Capitalize: TagRenderer {
    /// Creates a new `Capitalize` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        /// Require exactly one parameter (thing to capitalize)
        try tag.requireParameterCount(1)

        /// Convert the item to a `String` or default to `""`.
        let string = tag.parameters[0].string?.capitalized ?? ""
        return Future.map(on: tag) { .string(string) }
    }
}
