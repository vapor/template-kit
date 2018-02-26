import Debugging

/// An error converting types.
public struct TemplateError: Debuggable {
    public let identifier: String
    public let reason: String
    public var sourceLocation: SourceLocation?
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

    internal static func serialize(reason: String, template: TemplateSource, source: SourceLocation) -> TemplateError {
        return TemplateError(
            identifier: "serialize",
            reason:  reason + " in " + template.makeReadable(),
            source: source
        )
    }

    public static func parse(reason: String, template: TemplateSource, source: SourceLocation) -> TemplateError {
        return TemplateError(
            identifier: "parse",
            reason: reason + " in " + template.makeReadable(),
            source: source
        )
    }
}

extension TemplateSource {
    fileprivate func makeReadable() -> String {
        return "\(file) line: \(line) column: \(column) range: \(range)"
    }
}
