/// Capitalizes a `String`-convertible item.
public final class Capitalize: TagRenderer {
    /// Creates a new `Capitalize` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        /// Require exactly one parameter (thing to capitalize)
        try parsed.requireParameterCount(1)

        /// Convert the item to a `String` or default to `""`.
        let string = parsed.parameters[0].string?.capitalized ?? ""
        return .string(string)
    }
}
