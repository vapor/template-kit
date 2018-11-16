/// This type allows for the template AST to be extended with custom functionality.
///
/// The `render` closure receives access to the `TemplateSerializer` which in-turn has
/// access to a container, renderer, context and more. This can be used to generate arbitrary
/// `Future<TemplateData>` return.
///
/// This is not being used for anything yet, but it is here in case any parsers would like
/// to add custom functionality in the future.
public struct TemplateCustom {
    /// Renders `TemplateData` using the current `TemplateSerializer`.
    public let render: (TemplateDataContext) throws -> TemplateData

    /// Creates a new `TemplateCustom`.
    ///
    /// - parameters:
    ///     - render: Renders `TemplateData` using the current `TemplateSerializer`.
    public init(_ render: @escaping (TemplateDataContext) throws -> TemplateData) {
        self.render = render
    }
}
