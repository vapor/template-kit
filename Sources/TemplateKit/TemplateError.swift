import Debugging

/// An error converting types.
public struct TemplateKitError: Debuggable {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String

    /// See `Debuggable`.
    public var sourceLocation: SourceLocation?

    /// See `Debuggable`.
    public var stackTrace: [String]

    /// Creates a new `TemplateKitError`.
    public init(
        identifier: String,
        reason: String,
        source: TemplateSource? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.identifier = identifier
        if let ts = source {
            self.reason = "\(reason) (\(ts))"
        } else {
            self.reason = reason
        }
        self.sourceLocation = SourceLocation(file: file, function: function, line: line, column: column, range: nil)
        self.stackTrace = TemplateKitError.makeStackTrace()
    }
}
