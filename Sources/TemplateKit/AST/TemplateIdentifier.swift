/// A reference to data in `TemplateDataContext` composed of one or more path components.
public struct TemplateIdentifier {
    /// Path to a value in `TemplateDataContext`.
    public var path: [CodingKey]

    /// Creates a new `TemplateIdentifier`.
    ///
    /// - parameters:
    ///     - path: Path to a value in `TemplateDataContext`.
    public init(path: [CodingKey]) {
        self.path = path
    }
}
