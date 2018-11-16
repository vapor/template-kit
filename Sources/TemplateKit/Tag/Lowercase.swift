/// Converts a `String` to all lowercase characters.
///
///     lowercase(<item>)
///
public final class Lowercase: TagRenderer {
    /// Creates a new `Lowercase` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        try tag.requireParameterCount(1)
        switch tag.parameters[0] {
        case .string(let string): return .string(string.lowercased())
        default: return .null
        }
    }
}
