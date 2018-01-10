public struct TemplateSource {
    public var file: String
    public let line: Int
    public let column: Int
    public let range: Range<Int>

    public init(file: String, line: Int, column: Int, range: Range<Int>) {
        self.file = file
        self.line = line
        self.column = column
        self.range = range
    }
}

/// Start of a source range
public struct TemplateSourceStart {
    public let file: String
    public let line: Int
    public let column: Int
    public let rangeStart: Int
}

extension TemplateByteScanner {
    /// Creates a source range starting location.
    public func makeSourceStart() -> TemplateSourceStart {
        return .init(file: file, line: line, column: column, rangeStart: offset)
    }

    /// Closes a source range start location with the current location.
    public func makeSource(using sourceStart: TemplateSourceStart) -> TemplateSource {
        return .init(
            file: sourceStart.file,
            line: sourceStart.line,
            column: sourceStart.column,
            range: sourceStart.rangeStart..<offset
        )
    }
}
