/// Capable of rendering instances of `TemplateTag` in the AST. Each invocation of a tag in a template
/// will result in a call to the identified `TagRenderer` with a `TagContext` containing the current
/// context.
public protocol TagRenderer {
    /// Renders a `TemplateData` to return to the `TemplateSerializer` for serialization.
    ///
    /// - parameters:
    ///     - tag: The `TagContext` containing information about the invocation of this tag.
    /// - returns: Serialized `TemplateData`.
    func render(tag: TagContext) throws -> TemplateData
}

// MARK: Global

/// Contains all default tags with default names.
public var defaultTags: [String: TagRenderer] {
    return [
        "": Print(),
        "contains": Contains(),
        "lowercase": Lowercase(),
        "uppercase": Uppercase(),
        "capitalize": Capitalize(),
        "count": Count(),
        "set": Var(),
        "get": Raw(),
        "date": DateFormat()
    ]
}
