/// Converts a `String` to all lowercase characters.
///
///     lowercase(<item>)
///
public final class Lowercase: TagRenderer {
    /// Creates a new `Lowercase` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let string = tag.parameters[0].string?.lowercased() ?? ""
        return Future.map(on: tag) { .string(string) }
    }
}
