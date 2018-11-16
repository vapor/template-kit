/// Embeds another template at the specified `path`.
///
/// This is similar to `#include` in C.
/// The resolved path will be supplied to `TemplateRenderer.render(_:_:)`.
public struct TemplateEmbed: CustomStringConvertible {
    /// `TemplateSyntax` that should resolve to a `String` path pointing to
    /// the location of the template to embed.
    public var path: TemplateSyntax

    /// Creates a new `TemplateEmbed`.
    ///
    /// - parameters:
    ///     - path: `TemplateSyntax` that should resolve to a `String` path pointing to
    ///             the location of the template to embed.
    public init(path: TemplateSyntax) {
        self.path = path
    }
    
    /// See `CustomStringConvertible`.
    public var description: String {
        return self.path.description
    }
}
