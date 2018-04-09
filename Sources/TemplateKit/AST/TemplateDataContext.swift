/// A reference wrapper around `TemplateData`. 
public final class TemplateDataContext {
    /// The referenced `TemplateData`
    public var data: TemplateData

    /// Create a new `TemplateDataContext`.
    public init(data: TemplateData) {
        self.data = data
    }
}
