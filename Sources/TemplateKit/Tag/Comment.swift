/// Ignores zero or more parameters always returning an empty `String`.
public final class Comment: TagRenderer {
    /// Creates a new `Comment` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        return Future.map(on: tag) { .string("") }
    }
}
