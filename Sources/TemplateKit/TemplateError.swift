import Debugging

/// An error converting types.
public struct TemplateError: Debuggable {
    public let identifier: String
    public let reason: String
    public var sourceLocation: SourceLocation
    public var stackTrace: [String]

    public init(
        identifier: String,
        reason: String,
        source: SourceLocation
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = TemplateError.makeStackTrace()
    }

    internal static func serialize(reason: String, source: TemplateSource) -> TemplateError {
        return TemplateError(
            identifier: "serialize",
            reason: reason,
            source: source.makeSourceLocation()
        )
    }

    public static func parse(reason: String, source: TemplateSource) -> TemplateError {
        return TemplateError(
            identifier: "parse",
            reason: reason,
            source: source.makeSourceLocation()
        )
    }
}

extension TemplateSource {
    public func makeSourceLocation() -> SourceLocation {
        return SourceLocation(
            file: file,
            function: range.description,
            line: UInt(line),
            column: UInt(column),
            range: Range<UInt>(uncheckedBounds: (lower: UInt(range.lowerBound), upper: UInt(range.upperBound)))
        )
    }
}
