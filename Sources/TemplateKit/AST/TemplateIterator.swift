public struct TemplateIterator {
    public var key: TemplateSyntax
    public var data: TemplateSyntax
    public var body: [TemplateSyntax]

    public init(
        key: TemplateSyntax,
        data: TemplateSyntax,
        body: [TemplateSyntax]
        ) {
        self.key = key
        self.data = data
        self.body = body
    }
}

extension TemplateIterator: CustomStringConvertible {
    public var description: String {
        return "\(key) \(data)"
    }
}
