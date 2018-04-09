/// Prints a parameter without HTML-escaping it (be careful!).
///
///     raw(<item>)
///
public final class Raw: TagRenderer {
    /// Creates a new `Raw` tag renderer.
    public init() { }

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        try parsed.requireNoBody()
        try parsed.requireParameterCount(1)
        let string = parsed.parameters[0].string ?? ""
        return .string(string)
    }
}
