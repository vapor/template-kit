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
        case .raw(let raw): return "raw(" + raw.description + ")"
        case .tag(let tag): return "tag(" + tag.description + ")"
        case .identifier(let id): return "id(" + id.description + ")"
        case .expression(let expr): return "expr(" + expr.description + ")"
        case .constant(let const): return "const(" + const.description + ")"
        case .embed(let embed): return "embed(" + embed.description + ")"
        case .conditional(let cond): return "cond(" + cond.description + ")"
        case .iterator(let it): return "while(" + it.description + ")"
        case .custom: return "custom()"
        }
    }
}
