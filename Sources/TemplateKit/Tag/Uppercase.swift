/// Converts a `String` to all uppercase characters.
///
///     uppercase(<item>)
///
public final class Uppercase: TagRenderer {
    /// Creates a new `Uppercase` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        try tag.requireParameterCount(1)
        switch tag.parameters[0] {
        case .string(let string): return .string(string.uppercased())
        default: return .null
        }
    }
}
