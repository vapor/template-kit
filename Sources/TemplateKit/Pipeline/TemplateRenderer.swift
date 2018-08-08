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

    /// The renderer's `Container`. This is passed to all `TagContext` created during serializatin.
    var container: Container { get }

    /// Parses the template bytes into an AST.
    /// See `TemplateParser`.
    var parser: TemplateParser { get }

    /// Used to cache parsed ASTs for performance. If `nil`, caching will be skipped (useful for development modes).
    var astCache: ASTCache? { get set }

    /// The specific template file ending. This will be appended automatically when embedding views.
    var templateFileEnding: String { get }

    /// Relative leading directory for none absolute paths.
    var relativeDirectory: String { get }
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
    public func render<E>(_ path: String, _ context: E, userInfo: [AnyHashable: Any]) -> Future<View> where E: Encodable {
        do {
            return try TemplateDataEncoder().encode(context, on: self.container).flatMap { context in
                return self.render(path, context, userInfo: userInfo)
            }
        } catch {
            return container.future(error: error)
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
    public func render(_ path: String, _ context: TemplateData, userInfo: [AnyHashable: Any] = [:]) -> Future<View> {
        do {
            let path = path.hasSuffix(templateFileEnding) ? path : path + templateFileEnding
            let absolutePath = path.hasPrefix("/") ? path : relativeDirectory + path
            
            let ast: [TemplateSyntax]
            if let cached = astCache?.storage[absolutePath] {
                ast = cached
            } else {
                guard let data = FileManager.default.contents(atPath: absolutePath) else {
                    throw TemplateKitError(
                        identifier: "fileNotFound",
                        reason: "No file was found at path: \(absolutePath)"
                    )
                }
                ast = try _parse(data, file: absolutePath)
                astCache?.storage[absolutePath] = ast
            }
            return _serialize(context, ast, file: absolutePath, userInfo: userInfo)
        } catch {
            return container.future(error: error)
        }
    }
    
    // MARK: Render Data
    
    /// Renders the template bytes into a view using the supplied `Encodable` object as context.
    ///
    /// - parameters:
    ///     - template: Raw template bytes.
    ///     - context: `Encodable` item that will be encoded to `TemplateData` and used as template context.
    ///     - userInfo: User-defined storage.
    /// - returns: `Future` containing the rendered `View`.
    public func render<E>(template: Data, _ context: E, userInfo: [AnyHashable: Any] = [:]) -> Future<View> where E: Encodable {
        do {
            return try TemplateDataEncoder().encode(context, on: self.container).flatMap { context in
                return self.render(template: template, context, userInfo: userInfo)
            }
        } catch {
            return container.future(error: error)
        }
    }
    
    /// Renders template bytes into a view using the supplied context.
    ///
    /// - parameters:
    ///     - template: Raw template bytes.
    ///     - context: `TemplateData` to expose as context to the template.
    ///     - file: Template description, will be used for generating errors.
    ///     - userInfo: User-defined storage.
    /// - returns: `Future` containing the rendered `View`.
    public func render(template: Data, _ context: TemplateData, file: String? = nil, userInfo: [AnyHashable: Any] = [:]) -> Future<View> {
        let path = file ?? "template"
        do {
            return try _serialize(context, _parse(template, file: path), file: path, userInfo: userInfo)
        } catch {
            return container.future(error: error)
        }
    }
    
    // MARK: Private
    
    /// Serializes an AST + Context
    private func _serialize(_ context: TemplateData, _ ast: [TemplateSyntax], file: String, userInfo: [AnyHashable: Any]) -> Future<View> {
        let serializer = TemplateSerializer(
            renderer: self,
            context: .init(data: context, userInfo: userInfo),
            using: self.container
        )
        return serializer.serialize(ast: ast)
    }
    
    /// Parses data to AST.
    private func _parse(_ template: Data, file: String) throws -> [TemplateSyntax] {
        print("PARSE: \(file)")
        let scanner = TemplateByteScanner(data: template, file: file)
        return try parser.parse(scanner: scanner)
    }
}
