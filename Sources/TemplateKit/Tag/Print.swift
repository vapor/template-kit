/// Prints a parameter, HTML-escaping it first.
///
///     print(<item>)
///
public final class Print: TagRenderer {
    /// Creates a new `Print` tag renderer.
    public init() { }

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        let string = tag.parameters[0].string ?? ""
        return Future.map(on: tag) { .string(string.htmlEscaped()) }
    }
}
