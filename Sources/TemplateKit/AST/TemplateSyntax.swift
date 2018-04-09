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
            let string = String(data: source.data, encoding: .utf8) ?? "n/a"
            return "Raw: \(string)"
        case .tag(let tag): return "Tag: \(tag)"
        case .identifier(let name): return "Identifier: \(name.path)"
        case .expression(let expr): return "Expression: (\(expr))"
        case .constant(let const): return "Contstant: \(const)"
        case .embed(let embed): return "Embed: \(embed.path)"
        case .conditional(let cond): return "Conditional: \(cond))"
        case .iterator(let it): return "Iterator: \(it)"
        case .custom: return "Custom: ()"
        }
    }
}
