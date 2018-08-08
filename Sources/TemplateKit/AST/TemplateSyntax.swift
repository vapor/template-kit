/// Top-level syntax type. Combines `TemplateSyntaxType` which contains the actual AST
/// node and `TemplateSource` which contains template-source location.
public struct TemplateSyntax: CustomStringConvertible {
    /// The AST-node type. See `TemplateSyntaxType`.
    public let type: TemplateSyntaxType

    /// Source location of this syntax expression.
    public let source: TemplateSource

    /// Creates a new `TemplateSyntax`.
    ///
    /// - parameters:
    ///     - type: The AST-node type. See `TemplateSyntaxType`.
    ///     - source: Source location of this syntax expression.
    public init(type: TemplateSyntaxType, source: TemplateSource) {
        self.type = type
        self.source = source
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        switch type {
        case .raw(let source):
            var string = String(data: source.data, encoding: .utf8) ?? "n/a"
            string = string.replacingOccurrences(of: "\n", with: "\\n")
            return "raw(\"\(string)\")"
        case .tag(let tag):
            let params = tag.parameters.map { $0.description }.joined(separator: ", ")
            return "tag(\"\(tag.name)\", [\(params)])"
        case .identifier(let name):
            let path = name.path.map { $0.stringValue }.joined(separator: ".")
            return "id(\(path))"
        case .expression(let expr): return "(\(expr))"
        case .constant(let const): return "\(const)"
        case .embed(let embed): return "embed\(embed.path)"
        case .conditional(let cond): return "cond(\(cond))"
        case .iterator(let it): return "while\(it)"
        case .custom: return "custom()"
        }
    }
}
