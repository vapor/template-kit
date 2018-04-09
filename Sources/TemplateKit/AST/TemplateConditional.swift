/// A conditional collection of syntax to execute if the specified condition is truthy.
///
///     if <condition> {
///         <body>
///     } else <next?> {
///         ...
///     }
///
public final class TemplateConditional: CustomStringConvertible {
    /// This `TemplateSyntax` will be evaluated for truthiness when determining whether
    /// or not to evaluate the `body`.
    public var condition: TemplateSyntax

    /// Collection of `TemplateSyntax` to evaluate if the `condition` is truthy.
    public var body: [TemplateSyntax]

    /// If `condition` is not truthy and this property is not `nil`, it will be evaluated.
    public var next: TemplateConditional?

    /// Creates a new `TemplateConditional`.
    ///
    /// - parameters:
    ///     - condition: This `TemplateSyntax` will be evaluated for truthiness when determining whether
    ///                  or not to evaluate the `body`.
    ///     - body: Collection of `TemplateSyntax` to evaluate if the `condition` is truthy.
    ///     - next: If `condition` is not truthy and this property is not `nil`, it will be evaluated.
    public init(condition: TemplateSyntax, body: [TemplateSyntax], next: TemplateConditional? = nil) {
        self.condition = condition
        self.body = body
        self.next = next
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        if let next = self.next {
            return "if (\(condition)) { \(body) } else { \(next) }"
        } else {
            return "if (\(condition)) { \(body) }"
        }
    }
}
