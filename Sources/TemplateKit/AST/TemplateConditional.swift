public final class TemplateConditional {
    public var condition: TemplateSyntax
    public var body: [TemplateSyntax]
    public var next: TemplateConditional?

    public init(
        condition: TemplateSyntax,
        body: [TemplateSyntax],
        next: TemplateConditional?
        ) {
        self.condition = condition
        self.body = body
        self.next = next
    }
}

extension TemplateConditional: CustomStringConvertible {
    public var description: String {
        return "\(condition) : \(next?.description ?? "n/a")"
    }
}
