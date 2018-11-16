import NIO

/// Renders raw template data (bytes) to `View`s.
///
/// `TemplateRenderer`s combine a generic `TemplateParser` with the `TemplateSerializer` class to serialize templates.
///
///  - `TemplateParser`: parses the template data into an AST.
///  - `TemplateSerializer`: serializes the AST into a view.
///
/// The `TemplateRenderer` is expected to provide a `TemplateParser` that parses its specific templating language.
/// The `templateFileEnding` should also be unique to that templating language.
///
/// See each protocol requirement for more information.
public protocol TemplateRenderer: ViewRenderer {
    /// The available tags. `TemplateTag`s found in the AST will be looked up using this dictionary.
    var tags: [String: TagRenderer] { get }

    /// Parses the template bytes into an AST.
    /// See `TemplateParser`.
    var parser: TemplateParser { get }

    /// Used to cache parsed ASTs for performance. If `nil`, caching will be skipped (useful for development modes).
    var astCache: ASTCache? { get set }

    /// The specific template file ending. This will be appended automatically when embedding views.
    var templateFileEnding: String { get }

    /// Relative leading directory for none absolute paths.
    var relativeDirectory: String { get }
    
    var baseContext: [String: TemplateData] { get }
    
    var fileIO: NonBlockingFileIO { get }
}

extension TemplateRenderer {
    /// See `ViewRenderer`.
    public var shouldCache: Bool {
        get { return astCache != nil }
        set {
            if newValue {
                astCache = .init()
            } else {
                astCache = nil
            }
        }
    }
}

extension TemplateRenderer {
    /// See `ViewRenderer`.
    public func render<E>(_ path: String, _ context: E, userInfo: [AnyHashable: Any]) -> EventLoopFuture<View> where E: Encodable {
        do {
            let context = try TemplateContextEncoder().encode(context, base: self.baseContext)
            return self.render(path, context, userInfo: userInfo)
        } catch {
            return self.eventLoop.newFailedFuture(error: error)
        }
    }
    
    // MARK: TemplateData
    
    /// Loads and renders a raw template at the supplied path.
    ///
    /// - parameters:
    ///     - path: Path to file contianing raw template bytes.
    ///     - context: `TemplateData` to expose as context to the template.
    ///     - userInfo: User-defined storage.
    /// - returns: `Future` containing the rendered `View`.
    public func render(_ path: String, _ context: [String: TemplateData], userInfo: [AnyHashable: Any] = [:]) -> EventLoopFuture<View> {
        let path = path.hasSuffix(self.templateFileEnding) ? path : path + self.templateFileEnding
        let absolutePath = path.hasPrefix("/") ? path : self.relativeDirectory + path
        
        if let cached = astCache?.storage[absolutePath] {
            do {
                let string = try _serialize(context, cached, file: absolutePath, userInfo: userInfo)
                return self.eventLoop.newSucceededFuture(result: View(data: string))
            } catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        } else {
            print(absolutePath)
            return self.fileIO.openFile(path: absolutePath, eventLoop: self.eventLoop).then { file, region in
                #warning("FIXME: share allocator")
                print(file)
                return self.fileIO.read(
                    fileRegion: region,
                    allocator: .init(),
                    eventLoop: self.eventLoop
                ).thenThrowing { data in
                    try file.close()
                    let ast = try self._parse(data, file: absolutePath)
                    self.astCache?.storage[absolutePath] = ast
                    return try self._serialize(context, ast, file: absolutePath, userInfo: userInfo)
                }.map { string in
                    return View(data: string)
                }
            }
        }
    }
    
//    // MARK: Render Data
//
//    /// Renders the template bytes into a view using the supplied `Encodable` object as context.
//    ///
//    /// - parameters:
//    ///     - template: Raw template bytes.
//    ///     - context: `Encodable` item that will be encoded to `TemplateData` and used as template context.
//    ///     - userInfo: User-defined storage.
//    /// - returns: `Future` containing the rendered `View`.
//    public func render<E>(template: Data, _ context: E, userInfo: [AnyHashable: Any] = [:]) -> Future<View> where E: Encodable {
//        do {
//            return try TemplateDataEncoder().encode(context, on: self.container).flatMap { context in
//                return self.render(template: template, context, userInfo: userInfo)
//            }
//        } catch {
//            return container.future(error: error)
//        }
//    }
//
//    /// Renders template bytes into a view using the supplied context.
//    ///
//    /// - parameters:
//    ///     - template: Raw template bytes.
//    ///     - context: `TemplateData` to expose as context to the template.
//    ///     - file: Template description, will be used for generating errors.
//    ///     - userInfo: User-defined storage.
//    /// - returns: `Future` containing the rendered `View`.
//    public func render(template: Data, _ context: TemplateData, file: String? = nil, userInfo: [AnyHashable: Any] = [:]) -> Future<View> {
//        let path = file ?? "template"
//        do {
//            return try _serialize(context, _parse(template, file: path), file: path, userInfo: userInfo)
//        } catch {
//            return container.future(error: error)
//        }
//    }
    
    // MARK: Private
    
    /// Serializes an AST + Context
    private func _serialize(_ context: [String: TemplateData], _ ast: [TemplateSyntax], file: String, userInfo: [AnyHashable: Any]) throws -> String {
        #warning("FIXME: load top-level embeds")
        let serializer = TemplateSerializer(
            context: .init(data: context, userInfo: userInfo)
        )
        return try serializer.serialize(ast: ast)
    }
    
    /// Parses data to AST.
    private func _parse(_ template: ByteBuffer, file: String) throws -> [TemplateSyntax] {
        let scanner = TemplateScanner(data: template, file: file)
        return try parser.parse(scanner: scanner)
    }
}
