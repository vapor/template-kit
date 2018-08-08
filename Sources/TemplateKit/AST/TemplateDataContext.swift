/// A reference wrapper around `TemplateData`. 
public final class TemplateDataContext {
    /// The referenced `TemplateData`
    public var data: TemplateData
    
    /// User-defined storage.
    public var userInfo: [AnyHashable: Any]

    /// Create a new `TemplateDataContext`.
    public init(data: TemplateData, userInfo: [AnyHashable: Any] = [:]) {
        self.data = data
        self.userInfo = userInfo
    }
}
