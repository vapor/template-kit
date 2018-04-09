/// Contains contextual information corresponding to a `TemplateTag` in the AST.
/// This information will be passed to the `TagRenderer` for the identified tag.
public struct TagContext {
    /// Name used for this tag as registered to the `TemplateRenderer`.
    public let name: String

    /// Resolved input parameters to this tag.
    public let parameters: [TemplateData]

    /// Optional tag body.
    public let body: [TemplateSyntax]?

    /// `TemplateSource` code location of this parsed tag
    public let source: TemplateSource

    /// Current `Container`, use this as a `Worker` or to create services.
    public let container: Container

    /// Use this `TemplateDataContext` to access to current `TemplateData`.
    public let context: TemplateDataContext

    /// The `TemplateSerializer`. that created this context.
    public let serializer: TemplateSerializer

    /// Creates a new `TagContext`.
    init(
        name: String,
        parameters: [TemplateData],
        body: [TemplateSyntax]?,
        source: TemplateSource,
        context: TemplateDataContext,
        serializer: TemplateSerializer,
        using container: Container
    ) {
        self.name = name
        self.parameters = parameters
        self.body = body
        self.source = source
        self.context = context
        self.serializer = serializer
        self.container = container
    }

    /// Create a general `TemplateTagError` with metadata such as the `TemplateSource`.
    ///
    /// - parameters:
    ///     - reason: Human-readable information about why the error happened.
    public func error(reason: String) -> TemplateKitError {
        return .init(
            identifier: "tag:\(name)",
            reason: reason,
            source: source
        )
    }

    /// Throws an error if the parameter count does not equal the supplied number `n`.
    public func requireParameterCount(_ n: Int) throws {
        guard parameters.count == n else {
            throw error(reason: "Invalid parameter count: \(parameters.count)/\(n)")
        }
    }

    /// Throws an error if this tag does not include a body.
    public func requireBody() throws -> [TemplateSyntax] {
        guard let body = body else {
            throw error(reason: "Missing body")
        }

        return body
    }

    /// Throws an error if this tag includes a body.
    public func requireNoBody() throws {
        guard body == nil else {
            throw error(reason: "Extraneous body")
        }
    }
}
