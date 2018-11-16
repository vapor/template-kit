/// Prints a parameter, HTML-escaping it first.
///
///     print(<item>)
///
public final class Print: TagRenderer {
    /// Creates a new `Print` tag renderer.
    public init() { }

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        switch tag.parameters[0] {
        case .string(let string): return .string(string.htmlEscaped())
        case .int(let int): return .string(int.description)
        case .bool(let bool): return .string(bool.description)
        case .double(let double): return .string(double.description)
        default: return .null
        }
    }
}
