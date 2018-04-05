/// A reference wrapper around `TemplateData`.
public final class TemplateDataContext {
    /// The wrapped `TemplateData`
    public var data: TemplateData

    /// Create a new `TemplateContext`.
    public init(data: TemplateData) {
        self.data = data
    }
}
