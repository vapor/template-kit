import Async
import TemplateKit
import Service

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

    /// See TemplateRenderer.container
    public var container: Container

    /// Create a new `MustacheRenderer`
    public init(tags: [String: TagRenderer] = defaultTags, using container: Container) {
        self.tags = tags
        self.parser = MustacheParser()
        self.astCache = .init()
        self.templateFileEnding = ".mustache"
        self.relativeDirectory = "/"
        self.container = container
    }
}
