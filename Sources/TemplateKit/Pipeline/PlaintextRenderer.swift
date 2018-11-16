import NIO

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
    public var eventLoop: EventLoop
    
    public var baseContext: [String : TemplateData]
    
    public var fileIO: NonBlockingFileIO

    /// Create a new `PlaintextRenderer`.
    public init(viewsDir: String, fileIO: NonBlockingFileIO, on eventLoop: EventLoop) {
        self.tags = [:]
        self.astCache = nil
        self.templateFileEnding = ""
        self.relativeDirectory = viewsDir
        self.eventLoop = eventLoop
        self.baseContext = [:]
        self.fileIO = fileIO
    }

    /// See `TemplateParser`.
    public func parse(scanner: TemplateScanner) throws -> [TemplateSyntax] {
        let plaintext = TemplateSyntax(
            type: .raw(TemplateRaw(data: scanner.data)),
            source: TemplateSource(file: "data", line: 0, column: 0, range: 0..<scanner.data.readableBytes)
        )
        return [plaintext]
    }
}
