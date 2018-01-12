import Async
import Foundation
import Service

/// Renders templates as plaintext.
public final class PlaintextRenderer: TemplateRenderer, TemplateParser {
    /// See TemplateRenderer.tags
    public var tags: [String : TagRenderer]

    /// See TemplateRenderer.parser
    public var parser: TemplateParser {
        return self
    }

    /// See TemplateRenderer.astCache
    public var astCache: ASTCache?

    /// See TemplateRenderer.templateFileEnding
    public var templateFileEnding: String

    /// See TemplateRenderer.relativeDirectory
    public var relativeDirectory: String

    /// See TemplateRenderer.container
    public var container: Container

    /// Create a new PlaintextRenderer
    public init(viewsDir: String, on container: Container) {
        self.tags = [:]
        self.astCache = nil
        self.templateFileEnding = ""
        self.relativeDirectory = viewsDir
        self.container = container
    }

    /// See TemplateParser.parser
    public func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax] {
        let plaintext = TemplateSyntax(
            type: .raw(TemplateRaw(data: scanner.data)),
            source: TemplateSource(file: scanner.file, line: 0, column: 0, range: 0..<scanner.data.count)
        )
        return [plaintext]
    }
}
