/// Converts a `String` to all uppercase characters.
///
///     uppercase(<item>)
///
public final class Uppercase: TagRenderer {
    /// Creates a new `Uppercase` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireParameterCount(1)
        let string = tag.parameters[0].string?.uppercased() ?? ""
        return Future.map(on: tag) { .string(string) }
    }
}
