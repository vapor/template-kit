/// An error converting types.
#warning("FIXME: enum?")
public struct TemplateKitError: Error {
    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public let reason: String
    
    public var source: TemplateSource?

    /// Creates a new `TemplateKitError`.
    public init(
        identifier: String,
        reason: String,
        source: TemplateSource? = nil
    ) {
        self.identifier = identifier
        self.reason = reason
        self.source = source
    }
}
