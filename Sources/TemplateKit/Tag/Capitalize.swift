/// Capitalizes a `String`.
///
///     capitalize(<item>)
public final class Capitalize: TagRenderer {
    /// Creates a new `Capitalize` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        try tag.requireParameterCount(1)
        switch tag.parameters[0] {
        case .string(let string): return .string(string.capitalized)
        default: return .null
        }
    }
}
