/// Caches a `TemplateRenderer`'s parsed ASTs.
public struct ASTCache {
    /// Internal AST storage.
    internal var storage: [String: [TemplateSyntax]]

    /// Creates a new `ASTCache`.
    public init() {
        storage = [:]
    }
}
