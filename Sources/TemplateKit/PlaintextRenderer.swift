import Async
import Foundation

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

    /// See TemplateRenderer.eventLoop
    public var eventLoop: EventLoop

    /// Create a new PlaintextRenderer
    public init(viewsDir: String, on worker: Worker) {
        self.tags = [:]
        self.astCache = nil
        self.templateFileEnding = ""
        self.relativeDirectory = viewsDir
        self.eventLoop = worker.eventLoop
    }

    /// See TemplateParser.parser
    public func parse(template: Data, file: String) throws -> [TemplateSyntax] {
        let plaintext = TemplateSyntax(
            type: .raw(TemplateRaw(data: template)),
            source: TemplateSource(file: file, line: 0, column: 0, range: 0..<template.count)
        )
        return [plaintext]
    }
}
