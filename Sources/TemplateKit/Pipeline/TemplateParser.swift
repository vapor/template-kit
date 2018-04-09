/// Capable of parsing bytes (from file or elsewhere) into a TemplateKit AST (collection of `TemplateSyntax`)
public protocol TemplateParser {
    /// Parses bytes from the supplied `TemplateByteScanner` into a TemplateKit AST.
    ///
    /// - parameters:
    ///     - scanner: `TemplateByteScanner` to parse bytes from.
    /// - returns: TemplateKit AST.
    func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax]
}
