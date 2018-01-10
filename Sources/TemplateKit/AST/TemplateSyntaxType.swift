public indirect enum TemplateSyntaxType {
    case raw(TemplateRaw)
    case tag(TemplateTag)
    case embed(TemplateEmbed)
    case conditional(TemplateConditional)
    case identifier(TemplateIdentifier)
    case constant(TemplateConstant)
    case iterator(TemplateIterator)
    case expression(TemplateExpression)
}

extension TemplateSyntaxType  {
    public var name: String {
        switch self {
        case .constant: return "constant"
        case .expression: return "expression"
        case .identifier: return "identifier"
        case .raw: return "raw"
        case .tag: return "tag"
        case .embed: return "embed"
        case .conditional: return "conditional"
        case .iterator: return "iterator"
        }
    }
}
