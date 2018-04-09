/// Prints a parameter without HTML-escaping it (be careful!).
///
///     raw(<item>)
///
public final class Raw: TagRenderer {
    /// Creates a new `Raw` tag renderer.
    public init() { }

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        let string = tag.parameters[0].string ?? ""
        return Future.map(on: tag) { .string(string) }
    }
}
