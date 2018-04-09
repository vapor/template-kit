/// Converts a `String` to all lowercase characters.
///
///     lowercase(<item>)
///
public final class Lowercase: TagRenderer {
    /// Creates a new `Lowercase` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        try parsed.requireParameterCount(1)
        let string = parsed.parameters[0].string?.lowercased() ?? ""
        return .string(string)
    }
}
