
/// Deprecated.
@available(*, deprecated, renamed: "TemplateKitError")
public typealias TemplateError = TemplateKitError

extension TemplateKitError {
    /// Deprecated.
    @available(*, deprecated, renamed: "init(identifier:reason:source:)")
    public static func parse(reason: String, template: TemplateSource, source: SourceLocation) -> TemplateKitError {
        return TemplateKitError(identifier: "parse", reason: reason, source: template)
    }

    /// Deprecated.
    @available(*, deprecated, renamed: "init(identifier:reason:source:)")
    public static func serialize(reason: String, template: TemplateSource, source: SourceLocation) -> TemplateKitError {
        return TemplateKitError(identifier: "serialize", reason: reason, source: template)
    }
}
