import NIO

/// Contains contextual information corresponding to a `TemplateTag` in the AST.
/// This information will be passed to the `TagRenderer` for the identified tag.
public final class TagContext {
    /// Name used for this tag as registered to the `TemplateRenderer`.
    public let name: String

    /// Resolved input parameters to this tag.
    public let parameters: [TemplateData]

    /// Optional tag body.
    public let body: TemplateData?

    /// `TemplateSource` code location of this parsed tag
    public let source: TemplateSource

    /// Use this `TemplateDataContext` to access to current `TemplateData`.
    public let context: TemplateDataContext

    /// Creates a new `TagContext`.
    public init(
        name: String,
        parameters: [TemplateData],
        body: TemplateData?,
        source: TemplateSource,
        context: TemplateDataContext
    ) {
        self.name = name
        self.parameters = parameters
        self.body = body
        self.source = source
        self.context = context
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
    public func requireBody() throws -> TemplateData {
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
