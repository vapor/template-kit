/// Capable of being encoded as `TemplateData`.
public protocol CustomTemplateDataConvertible {
    /// Converts `self` to `TemplateData` or throws an error if `self`
    /// cannot be converted.
    var templateData: TemplateData { get }
}
