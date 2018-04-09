/// Renders templates as plaintext.
public final class PlaintextRenderer: TemplateRenderer, TemplateParser {
    /// See `TemplateRenderer`.
    public var tags: [String: TagRenderer]

    /// See `TemplateRenderer`.
    public var parser: TemplateParser {
        return self
    }

    /// See `TemplateRenderer`.
    public var astCache: ASTCache?

    /// See `TemplateRenderer`.
    public var templateFileEnding: String

    /// See `TemplateRenderer`.
    public var relativeDirectory: String

    /// See `TemplateRenderer`.
    public var container: Container

    /// Create a new `PlaintextRenderer`.
    public init(viewsDir: String, on container: Container) {
        self.tags = [:]
        self.astCache = nil
        self.templateFileEnding = ""
        self.relativeDirectory = viewsDir
        self.container = container
    }

    /// See `TemplateParser`.
    public func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax] {
        let plaintext = TemplateSyntax(
            type: .raw(TemplateRaw(data: scanner.data)),
            source: TemplateSource(file: scanner.file, line: 0, column: 0, range: 0..<scanner.data.count)
        )
        return [plaintext]
    }
}
