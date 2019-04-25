/// Serializes parsed AST, using context, into `View`s.
///
/// See `TemplateRenderer` for more information.
public final class TemplateSerializer {
    /// The serializer's parent `TemplateRenderer`.
    public let renderer: TemplateRenderer

    /// The current `TemplateDataContext`.
    public let context: TemplateDataContext

    /// The serializer's `Container`. Used to create `TagContext`s.
    public let container: Container

    /// Creates a new `TemplateSerializer`.
    public init(renderer: TemplateRenderer, context: TemplateDataContext, using container: Container) {
        self.renderer = renderer
        self.context = context
        self.container = container
    }

    /// Serializes the supplied AST into a `View`.
    ///
    /// - parameters:
    ///     - ast: Collection of `TemplateSyntax` (AST) to serialize using this serializer's context and container.
    /// - returns: A `Future` `View` containing the rendered template.
    public func serialize(ast: [TemplateSyntax]) -> Future<View> {
        return Future<TemplateData>.flatMap(on: container) {
            return try self.render(ast: ast)
        }.map(to: Data.self) { context in
            if case .null = context {
                return .init()
            }

            guard let data = context.data else {
                throw TemplateKitError(
                    identifier: "serialize",
                    reason: "Unable to convert tag return type to Data: \(context)"
                )
            }
            return data
        }.map(to: View.self) { data in
            return View(data: data)
        }
    }

    // MARK: Private

    /// Renders a `[TemplateSyntax]` to future `View`.
    private func render(ast: [TemplateSyntax]) throws -> Future<TemplateData> {
        return try ast.map { syntax -> Future<TemplateData> in
            return try self.render(syntax: syntax)
        }.map(to: TemplateData.self, on: container) { parts in
            return .array(parts)
        }
    }

    // Renders a `TemplateTag` to future `TemplateData`.
    private func render(tag: TemplateTag, source: TemplateSource) throws -> Future<TemplateData> {
        guard let tagRenderer = self.renderer.tags[tag.name] else {
            throw TemplateKitError(
                identifier: "missingTag",
                reason: "No tag named `\(tag.name)` is registered.",
                source: source
            )
        }

        return try tag.parameters.map { parameter in
            return try self.render(syntax: parameter)
        }.flatMap(to: TemplateData.self, on: container) { inputs in
            let tagContext = TagContext(
                name: tag.name,
                parameters: inputs,
                body: tag.body,
                source: source,
                context: self.context,
                serializer: self,
                using: self.container
            )

            return try tagRenderer.render(tag: tagContext)
        }
    }

    // Renders a `TemplateConstant` to future `TemplateData`.
    private func render(constant: TemplateConstant, source: TemplateSource) -> Future<TemplateData> {
        switch constant {
        case .bool(let bool):
            return Future.map(on: container) { .bool(bool) }
        case .double(let double):
            return Future.map(on: container) { .double(double) }
        case .int(let int):
            return Future.map(on: container) { .int(int) }
        case .string(let string):
            return Future.map(on: container) { .string(string) }
        case .interpolated(let ast):
            return serialize(ast: ast).map(to: TemplateData.self) { view in
                return .data(view.data)
            }
        }
    }

    // Renders an infix `TemplateExpression` to future `TemplateData`.
    private func render(infix: TemplateExpression.InfixOperator, left: TemplateSyntax, right: TemplateSyntax, source: TemplateSource) throws -> Future<TemplateData> {
        return try map(to: TemplateData.self, render(syntax: left), render(syntax: right)) { left, right in
            switch infix {
            case .equal: return .bool(left == right)
            case .notEqual: return .bool(left != right)
            case .and: return .bool(left.bool != false && right.bool != false)
            case .or: return .bool(left.bool != false || right.bool != false)
            default:
                switch (left.storage, right.storage) {
                case (.int(let a), .int(let b)):
                    // integer math
                    switch infix {
                    case .add: return .int(a + b)
                    case .subtract: return .int(a - b)
                    case .multiply: return .int(a * b)
                    case .divide: return .int(a / b)
                    case .modulo: return .int(a % b)
                    case .greaterThan: return .bool(a > b)
                    case .lessThan: return .bool(a < b)
                    default:
                        throw TemplateKitError(
                            identifier: "renderInfix",
                            reason: "Unsupported infix operator: \(infix).",
                            source: source
                        )
                    }
                default:
                    // default to double conversion math
                    guard let leftDouble = left.double, let rightDouble = right.double else {
                        return .bool(false)
                    }
                    switch infix {
                    case .add: return .double(leftDouble + rightDouble)
                    case .subtract: return .double(leftDouble - rightDouble)
                    case .multiply: return .double(leftDouble * rightDouble)
                    case .divide: return .double(leftDouble / rightDouble)
                    case .modulo: return .double(leftDouble.truncatingRemainder(dividingBy: rightDouble))
                    case .greaterThan: return .bool(leftDouble > rightDouble)
                    case .lessThan: return .bool(leftDouble < rightDouble)
                    default:
                        throw TemplateKitError(
                            identifier: "renderInfix",
                            reason: "Unsupported infix operator: \(infix).",
                            source: source
                        )
                    }
                }
            }
        }
    }

    // Renders an prefix `TemplateExpression` to future `TemplateData`.
    private func render(prefix: TemplateExpression.PrefixOperator, right: TemplateSyntax, source: TemplateSource) throws -> Future<TemplateData> {
        return try render(syntax: right).map(to: TemplateData.self) { right in
            switch prefix {
            case .not: return .bool(right.bool.flatMap { !$0 } ?? false)
            }
        }
    }

    // Renders `TemplateConditional` to future `TemplateData`.
    private func render(conditional: TemplateConditional, source: TemplateSource) throws -> Future<TemplateData> {
        return try self.render(syntax: conditional.condition).flatMap(to: TemplateData.self) { data in
            if !data.isNull && data.bool != false {
                return try self.render(ast: conditional.body)
            } else if let next = conditional.next {
                return try self.render(conditional: next, source: source)
            } else {
                return Future.map(on: self.container) { .null }
            }
        }
    }

    // Renders `TemplateEmbed` to future `TemplateData`.
    private func render(embed: TemplateEmbed, source: TemplateSource) throws -> Future<TemplateData> {
        return try render(syntax: embed.path).flatMap(to: TemplateData.self) { path in
            guard let path = path.string else {
                throw TemplateKitError(
                    identifier: "embedPath",
                    reason: "Unable to convert embed path to string.",
                    source: source
                )
            }

            return self.renderer.render(path, self.context.data, userInfo: self.context.userInfo)
                .map(to: TemplateData.self) { .data($0.data) }
        }
    }


    // Renders `TemplateIterator` to future `TemplateData`.
    private func render(iterator: TemplateIterator, source: TemplateSource) throws -> Future<TemplateData> {
        return try flatMap(to: TemplateData.self, render(syntax: iterator.key), render(syntax: iterator.data)) { key, data in
            guard let key = key.string else {
                throw TemplateKitError(
                    identifier: "iteratorKey",
                    reason: "Could not convert iterator key to string.",
                    source: source
                )
            }

            func renderIteration(item: TemplateData, index: Int, count: Int) -> Future<View> {
                var copy = self.context.data.dictionary ?? [:]
                copy[key] = item
                copy["index"] = .int(index)
                copy["isFirst"] = .bool(index == 0)
                copy["isLast"] = .bool(index == count - 1)
                let serializer = TemplateSerializer(
                    renderer: self.renderer,
                    context: .init(data: .dictionary(copy), userInfo: self.context.userInfo),
                    using: self.container
                )
                return serializer.serialize(ast: iterator.body)
            }

            func merge(views: [Future<View>]) -> Future<TemplateData> {
                return views.map(to: TemplateData.self, on: self.container) { views in
                    var data = Data()
                    for view in views {
                        data += view.data
                    }
                    return .data(data)
                }
            }
            
            guard !data.isNull else {
                return Future.map(on: self.container) { .null }
            }

            guard let data = data.array else {
                throw TemplateKitError(
                    identifier: "iteratorData",
                    reason: "Could not convert iterator data to array.",
                    source: source
                )
            }

            let views = data.enumerated().map { (i, item) -> Future<View> in
                renderIteration(item: item, index: i, count: data.count)
            }

            return merge(views: views)
        }
    }

    // Renders `TemplateSyntax` to future `TemplateData`.
    private func render(syntax: TemplateSyntax) throws -> Future<TemplateData> {
        switch syntax.type {
        case .constant(let constant): return render(constant: constant, source: syntax.source)
        case .expression(let expr):
            switch expr {
            case .infix(let op, let left, let right): return try render(infix: op, left: left, right: right, source: syntax.source)
            case .prefix(let op, let right): return try render(prefix: op, right: right, source: syntax.source)
            case .postfix:
                throw TemplateKitError(
                    identifier: "postfix",
                    reason: "Unsupported postfix expression: \(expr).",
                    source: syntax.source
                )
            }
        case .identifier(let id):
            let data = context.data.get(at: id.path) ?? .null
            return Future.map(on: container) { data }
        case .tag(let tag): return try render(tag: tag, source: syntax.source)
        case .raw(let raw): return Future.map(on: container) { .data(raw.data) }
        case .conditional(let cond): return try render(conditional: cond, source: syntax.source)
        case .embed(let embed): return try render(embed: embed, source: syntax.source)
        case .iterator(let it): return try render(iterator: it, source: syntax.source)
        case .custom(let cust): return cust.render(self)
        }
    }
}
