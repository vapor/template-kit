/// An invocation of a tag that has been registered with the `TemplateRenderer`. This is equivalent
/// to a function call in Swift.
///
///     <name>(<params>, <body>)
///
/// The `body` is a special, additional parameter. It is optional and represents some portion of template
/// that is associated with this tag.
///
/// In the Leaf templating language, template bodies come after `{`.
///
///     #set("foo") { hello }
///
/// The above snippet sets `"hello"` into the context at key `"foo"`.
public struct TemplateTag: CustomStringConvertible {
    /// Name of `TagRenderer` to invoke.
    /// There should be a matching tag in `TemplateRenderer.tags` or this will result in an error.
    public var name: String

    /// Collection of parameters that have been passed to this tag invocation.
    public var parameters: [TemplateSyntax]

    /// Optional collection of template syntax associated with this tag invocation.
    public var body: [TemplateSyntax]?

    /// Creates a new `TemplateTag`.
    ///
    /// - parameters:
    ///     - name: Name of `TagRenderer` to invoke.
    ///             There should be a matching tag in `TemplateRenderer.tags` or this will result in an error.
    ///     - parameters: Collection of parameters that have been passed to this tag invocation.
    ///     - body: Optional collection of template syntax associated with this tag invocation.
    public init(name: String, parameters: [TemplateSyntax], body: [TemplateSyntax]?) {
        self.name = name
        self.parameters = parameters
        self.body = body
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        let params = parameters.map { $0.description }
        let hasBody = body != nil ? true : false
        return "\(name)(\(params.joined(separator: ", "))) \(hasBody)"
    }
}
