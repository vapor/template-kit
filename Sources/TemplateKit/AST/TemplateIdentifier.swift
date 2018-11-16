/// A reference to data in `TemplateDataContext` composed of one or more path components.
public struct TemplateIdentifier: CustomStringConvertible {
    /// Path to a value in `TemplateDataContext`.
    public var path: [String]

    /// Creates a new `TemplateIdentifier`.
    ///
    /// - parameters:
    ///     - path: Path to a value in `TemplateDataContext`.
    public init(path: [String]) {
        self.path = path
    }
    
    /// See `CustomStringConvertible`.
    public var description: String {
        return self.path.joined(separator: ".")
    }
}
