import NIO

/// A chunk of `Data` to be rendered. This is used to represent the large
/// chunks of text between invocations of the templating language.
public struct TemplateRaw: CustomStringConvertible {
    /// Chunk of `Data` to be rendered as-is.
    public let data: ByteBuffer

    /// Creates a new `TemplateRaw`.
    ///
    /// - parameters:
    ///     - data: Chunk of `Data` to be rendered as-is.
    public init(data: ByteBuffer) {
        self.data = data
    }

    /// See `CustomStringConvertible`
    public var description: String {
        return data.readableBytes.description
    }
}
