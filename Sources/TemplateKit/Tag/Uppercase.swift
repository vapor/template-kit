/// Converts a `String` to all uppercase characters.
///
///     uppercase(<item>)
///
public final class Uppercase: TagRenderer {
    /// Creates a new `Uppercase` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        try parsed.requireParameterCount(1)
        let string = parsed.parameters[0].string?.uppercased() ?? ""
        return .string(string)
    }
}
