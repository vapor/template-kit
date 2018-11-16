import NIO

/// A rendered template.
public struct View {
    /// The view's raw data.
    public let data: String

    /// Create a new `View`.
    public init(data: String) {
        self.data = data
    }
}
