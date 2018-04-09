/// A chunk of `Data` to be rendered. This is used to represent the large
/// chunks of text between invocations of the templating language.
public struct TemplateRaw: CustomStringConvertible {
    /// Chunk of `Data` to be rendered as-is.
    public var data: Data

    /// Creates a new `TemplateRaw`.
    ///
    /// - parameters:
    ///     - data: Chunk of `Data` to be rendered as-is.
    public init(data: Data) {
        self.data = data
    }

    /// See `CustomStringConvertible`
    public var description: String {
        return "raw(\(data.count))"
    }
}
