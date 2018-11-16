/// Represents a location in a template's source file.
///
/// Every `TemplateSyntax` struct has an associated `TemplateSource`. This helps generate better
/// debug information when something goes wrong.
public struct TemplateSource: CustomStringConvertible {
    /// Path to the template file.
    public var file: String

    /// Line number.
    public let line: Int

    /// Column number.
    public let column: Int

    /// Character offset range (starting from first character == 0).
    public let range: Range<Int>

    /// Creates a new `TemplateSource`.
    ///
    /// - parameters:
    ///     - file: Path to the template file.
    ///     - line: Line number.
    ///     - column: Column number.
    ///     - range: Character offset range (starting from first character == 0).
    public init(file: String, line: Int, column: Int, range: Range<Int>) {
        self.file = file
        self.line = line
        self.column = column
        self.range = range
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        return "\(file) line: \(line) column: \(column) range: \(range)"
    }
}

extension TemplateSource {
    /// Start of a source range. This type is useful for marking the start of a `TemplateSource` when
    /// using a `TemplateByteScanner`.
    ///
    /// See `TemplateByteScanner`.
    public struct Start {
        /// Path to the template file.
        public let file: String
        
        /// Line number.
        public let line: Int
        
        /// Column number.
        public let column: Int
        
        /// Character offset (starting from first character == 0).
        /// This will be used to generate the `TemplateSource.range`.
        public let offset: Int
        
        /// Creates a new `TemplateSourceStart`.
        ///
        /// - parameters:
        ///     - file: Path to the template file.
        ///     - line: Line number.
        ///     - column: Column number.
        ///     - offset: Character offset (starting from first character == 0).
        ///               This will be used to generate the `TemplateSource.range`.
        public init(file: String, line: Int, column: Int, offset: Int) {
            self.file = file
            self.line = line
            self.column = column
            self.offset = offset
        }
    }

}
extension TemplateScanner {
    /// Creates a new `TemplateSourceStart` at the current location.
    public func makeSourceStart() -> TemplateSource.Start {
        #warning("FIXME: implement source start")
        return .init(file: file, line: 0, column: 0, offset: 0)
    }

    /// Closes a `TemplateSourceStart` at the current location, creating a `TemplateSource`.
    ///
    /// - parameters:
    ///     - sourceStart: `TemplateSourceStart` to complete.
    public func makeSource(using sourceStart: TemplateSource.Start) -> TemplateSource {
        #warning("FIXME: implement end source")
        return .init(
            file: sourceStart.file,
            line: sourceStart.line,
            column: sourceStart.column,
            range: sourceStart.offset..<Int.max
        )
    }
}
