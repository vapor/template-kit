public struct TemplateSyntax {
    public let type: TemplateSyntaxType
    public let source: TemplateSource

    public init(type: TemplateSyntaxType, source: TemplateSource) {
        self.type = type
        self.source = source
    }
}

extension TemplateSyntax: CustomStringConvertible {
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
        }
    }
}
