/// Prints a parameter, HTML-escaping it first.
///
///     print(<item>)
///
public final class Print: TagRenderer {
    /// Creates a new `Print` tag renderer.
    public init() { }

    /// See `TagRenderer`.
    public func render(tag parsed: TagContext) throws -> TemplateData {
        try parsed.requireNoBody()
        try parsed.requireParameterCount(1)
        let string = parsed.parameters[0].string ?? ""
        return .string(string.htmlEscaped())
    }
}

