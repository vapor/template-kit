/// Iterates over an array of `data`, allowing each item to be accessed as `key`.
///
///     for <key> in <data> {
///         <body> // with access to key
///     }
///
public struct TemplateIterator: CustomStringConvertible {
    /// A `TemplateSyntax` that resolves to an identifier to use for referencing each element.
    public var key: TemplateSyntax

    /// A `TemplateSyntax` that resolves an array of elements.
    public var data: TemplateSyntax

    /// A collection of `TemplateSyntax` to be evaluated for each iteration.
    public var body: [TemplateSyntax]

    /// Creates a new `TemplateIterator`.
    ///
    /// - parameters:
    ///     - key: A `TemplateSyntax` that resolves to an identifier to use for referencing each element.
    ///     - data: A `TemplateSyntax` that resolves an array of elements.
    ///     - body: A collection of `TemplateSyntax` to be evaluated for each iteration.
    public init(key: TemplateSyntax, data: TemplateSyntax, body: [TemplateSyntax]) {
        self.key = key
        self.data = data
        self.body = body
    }

    /// See `CustomStringConvertible`
    public var description: String {
        return "for \(key) in \(data) { \(body) }"
    }
}
