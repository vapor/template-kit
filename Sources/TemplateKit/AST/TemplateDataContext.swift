/// A reference wrapper around `TemplateData`. 
public final class TemplateDataContext {
    /// The referenced `TemplateData`
    public var data: [String: TemplateData]
    
    /// User-defined storage.
    public var userInfo: [AnyHashable: Any]

    /// Create a new `TemplateDataContext`.
    public init(data: [String: TemplateData], userInfo: [AnyHashable: Any] = [:]) {
        self.data = data
        self.userInfo = userInfo
    }
}
