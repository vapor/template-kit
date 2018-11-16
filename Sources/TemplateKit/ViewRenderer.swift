import NIO

/// Renders an Encodable object into a `View`.
public protocol ViewRenderer: class {
    /// The renderer's `Container`. This is passed to all `TagContext` created during serializatin.
    var eventLoop: EventLoop { get }
    
    /// For view renderers that use a cache to optimize view loads, use this variable to toggle whether or not cache should be implemented
    ///
    /// Normally, cache is disabled in development so views can be tested w/o recompilation.
    /// - note: In production, cache is enabled to optimize view serving speed.
    var shouldCache: Bool { get set }

    /// Renders the template bytes into a view using the supplied `Encodable` object as context.
    ///
    /// - parameters:
    ///     - path: Path to file contianing raw template bytes.
    ///     - context: `Encodable` item that will be encoded to `TemplateData` and used as template context.
    ///     - userInfo: User-defined storage.
    /// - returns: `Future` containing the rendered `View`.
    func render<E>(_ path: String, _ context: E, userInfo: [AnyHashable: Any]) -> EventLoopFuture<View>
        where E: Encodable
}

extension ViewRenderer {
    /// Renders the template bytes into a view using the supplied `Encodable` object as context.
    ///
    /// - parameters:
    ///     - path: Path to file contianing raw template bytes.
    ///     - context: `Encodable` item that will be encoded to `TemplateData` and used as template context.
    /// - returns: `Future` containing the rendered `View`.
    public func render<E>(_ path: String, _ context: E) -> EventLoopFuture<View>
        where E: Encodable
    {
        return render(path, context, userInfo: [:])
    }
    
    /// Loads and renders a raw template at the supplied path using an empty context.
    ///
    /// - parameters:
    ///     - path: Path to file contianing raw template bytes.
    ///     - userInfo: User-defined storage.
    /// - returns: `Future` containing the rendered `View`.
    public func render(_ path: String, userInfo: [AnyHashable: Any] = [:]) -> EventLoopFuture<View> {
        return render(path, Dictionary<String, String>(), userInfo: userInfo)
    }
}
