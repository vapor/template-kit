import Async
import Foundation

/// Parses template data into AST.
public protocol TemplateParser {
    func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax]
}
