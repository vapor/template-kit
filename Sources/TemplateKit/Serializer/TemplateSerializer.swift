import Async
import Dispatch
import Foundation
import Service

/// Serializes parsed AST, using context, into view bytes.
public final class TemplateSerializer {
    /// The serializer's parent renderer.
    public let renderer: TemplateRenderer

    /// The current context.
    public let context: TemplateContext

    /// The serializer's container.
    public let container: Container

    /// Creates a new TemplateSerializer
    public init(renderer: TemplateRenderer, context: TemplateContext, using container: Container) {
        self.renderer = renderer
        self.context = context
        self.container = container
    }

    /// Serializes the AST into Bytes.
    public func serialize(ast: [TemplateSyntax]) -> Future<View> {
        return Future<TemplateData>.flatMap(on: container) { try self.render(ast: ast) }.map(to: Data.self) { context in
            if case .null = context {
                return Data()
            }

            guard let data = context.data else {
                throw TemplateError(
                    identifier: "serialize",
                    reason: "Unable to convert tag return type to Data: \(context)",
                    source: .capture()
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
            throw TemplateError.serialize(reason: "No tag named `\(tag.name)` is registered.", template: source, source: .capture())
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
        case .string(let ast):
            return serialize(ast: ast).map(to: TemplateData.self) { view in
                return .data(view.data)
            }
        }
    }

    // Renders an infix `TemplateExpression` to future `TemplateData`.
    private func render(infix: ExpressionInfixOperator, left: TemplateSyntax, right: TemplateSyntax, source: TemplateSource) throws -> Future<TemplateData> {
        return try map(to: TemplateData.self, render(syntax: left), render(syntax: right)) { left, right in
            switch infix {
            case .equal: return .bool(left == right)
            case .notEqual: return .bool(left != right)
            case .and: return .bool(left.bool != false && right.bool != false)
            case .or: return .bool(left.bool != false || right.bool != false)
            default:
                guard let leftDouble = left.double, let rightDouble = right.double else {
                    return .bool(false)
                }
                switch infix {
                case .add: return .double(leftDouble + rightDouble)
                case .subtract: return .double(leftDouble - rightDouble)
                case .multiply: return .double(leftDouble * rightDouble)
                case .divide: return .double(leftDouble / rightDouble)
                case .greaterThan: return .bool(leftDouble > rightDouble)
                case .lessThan: return .bool(leftDouble < rightDouble)
                default:
                    throw TemplateError.serialize(
                        reason: "Unsupported infix operator: \(infix) at \(source)", template: source, source: .capture()
                    )
                }
            }
        }
    }

    // Renders an prefix `TemplateExpression` to future `TemplateData`.
    private func render(prefix: ExpressionPrefixOperator, right: TemplateSyntax, source: TemplateSource) throws -> Future<TemplateData> {
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
                throw TemplateError.serialize(reason: "Unable to convert embed path to string.", template: source, source: .capture())
            }

            return self.renderer.render(path, self.context.data)
                .map(to: TemplateData.self) { .data($0.data) }
        }
    }


    // Renders `TemplateIterator` to future `TemplateData`.
    private func render(iterator: TemplateIterator, source: TemplateSource) throws -> Future<TemplateData> {
        return try flatMap(to: TemplateData.self, render(syntax: iterator.key), render(syntax: iterator.data)) { key, data in
            guard let key = key.string else {
                throw TemplateError.serialize(reason: "Could not convert iterator key to string.", template: source, source: .capture())
            }

            func renderIteration(item: TemplateData, index: Int) -> Future<View> {
                var copy = self.context.data.dictionary ?? [:]
                copy[key] = item
                copy["index"] = .int(index)
                let serializer = TemplateSerializer(
                    renderer: self.renderer,
                    context: .init(data: .dictionary(copy), on: self.container),
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

            switch data {
//            case .stream(let stream):
//                let promise = container.eventLoop.newPromise(TemplateData.self)
//
//                /// handle streaming bodies
//                var views: [Future<View>] = []
//                var index = 0
//
//                stream.drain { item in
//                    let view = renderIteration(item: item, index: index)
//                    index += 1
//                    views.append(view)
//                }.catch { error in
//                    promise.fail(error)
//                }.finally {
//                    merge(views: views).chain(to: promise)
//                }
//                return promise.future
            default:
                guard let data = data.array else {
                    throw TemplateError.serialize(reason: "Could not convert iterator data to array.", template: source, source: .capture())
                }

                let views = data.enumerated().map { (i, item) -> Future<View> in
                    renderIteration(item: item, index: i)
                }

                return merge(views: views)
            }
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
                throw TemplateError.serialize(
                    reason: "Unsupported expression: \(expr) at \(syntax.source)", template: syntax.source, source: .capture()
                )
            }
        case .identifier(let id): return context.fetch(at: id.path)
        case .tag(let tag): return try render(tag: tag, source: syntax.source)
        case .raw(let raw): return Future.map(on: container) { .data(raw.data) }
        case .conditional(let cond): return try render(conditional: cond, source: syntax.source)
        case .embed(let embed): return try render(embed: embed, source: syntax.source)
        case .iterator(let it): return try render(iterator: it, source: syntax.source)
        }
    }
}
