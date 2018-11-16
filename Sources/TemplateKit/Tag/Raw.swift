/// Prints a parameter without HTML-escaping it (be careful!).
///
///     raw(<item>)
///
public final class Raw: TagRenderer {
    /// Creates a new `Raw` tag renderer.
    public init() { }

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        return tag.parameters[0]
    }
}
