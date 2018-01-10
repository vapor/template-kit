import Async
import TemplateKit

/// Renders mustache templates using the `MustacheParser`.
public final class MustacheRenderer: TemplateRenderer {
    /// See TemplateRenderer.tags
    public var tags: [String: TagRenderer]

    /// See TemplateRenderer.parser
    public var parser: TemplateParser

    /// See TemplateRenderer.astCache
    public var astCache: ASTCache?

    /// See TemplateRenderer.templateFileEnding
    public var templateFileEnding: String

    /// See TemplateRenderer.relativeDirectory
    public var relativeDirectory: String

    /// See TemplateRenderer.eventLoop
    public var eventLoop: EventLoop

    /// Create a new `MustacheRenderer`
    public init(tags: [String: TagRenderer] = defaultTags, on worker: Worker) {
        self.tags = tags
        self.parser = MustacheParser()
        self.astCache = .init()
        self.templateFileEnding = ".mustache"
        self.relativeDirectory = "/"
        self.eventLoop = worker.eventLoop
    }
}
