/// Serializes parsed AST, using context, into `View`s.
///
/// See `TemplateRenderer` for more information.
internal final class TemplateSerializer {
    /// The current `TemplateDataContext`.
    public let context: TemplateDataContext

    /// Creates a new `TemplateSerializer`.
    public init(context: TemplateDataContext) {
        self.context = context
    }

    /// Serializes the supplied AST into a `View`.
    ///
    /// - parameters:
    ///     - ast: Collection of `TemplateSyntax` (AST) to serialize using this serializer's context and container.
    /// - returns: A `Future` `View` containing the rendered template.
    public func serialize(ast: [TemplateSyntax]) throws -> String {
        return try self.render(ast: ast).map { data -> String in
            switch data {
            case .null: return ""
            case .string(let string): return string
            case .int(let int): return int.description
            default:
                throw TemplateKitError(
                    identifier: "serialize",
                    reason: "Unable to serialize data: \(data)"
                )
            }
        }.joined()
    }

    // MARK: Private

    /// Renders a `[TemplateSyntax]` to future `View`.
    private func render(ast: [TemplateSyntax]) throws -> [TemplateData] {
        return try ast.map { syntax -> TemplateData in
            return try self.render(syntax: syntax)
        }
    }

    
    // Renders `TemplateSyntax` to future `TemplateData`.
    private func render(syntax: TemplateSyntax) throws -> TemplateData {
        switch syntax.type {
        case .constant(let constant): return try render(constant: constant, source: syntax.source)
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
            return TemplateData.dictionary(context.data).get(at: id.path) ?? .null
        case .tag(let tag): fatalError() // return try render(tag: tag, source: syntax.source)
        case .raw(let raw):
            var data = raw.data
            return .string(data.readString(length: data.readableBytes) ?? "")
        case .conditional(let cond): return try render(conditional: cond, source: syntax.source)
        case .embed(let embed): return try render(embed: embed, source: syntax.source)
        case .iterator(let it): return try render(iterator: it, source: syntax.source)
        case .custom(let cust): return try cust.render(self.context)
        }
    }
    
//    // Renders a `TemplateTag` to future `TemplateData`.
//    private func render(tag: TemplateTag, source: TemplateSource) throws -> TemplateData {
//        guard let tagRenderer = self.renderer.tags[tag.name] else {
//            throw TemplateKitError(
//                identifier: "missingTag",
//                reason: "No tag named `\(tag.name)` is registered.",
//                source: source
//            )
//        }
//
//        let inputs = try tag.parameters.map { parameter in
//            return try self.render(syntax: parameter)
//        }
//
//        let tagContext = try TagContext(
//            name: tag.name,
//            parameters: inputs,
//            body: tag.body.flatMap { try .string(self.serialize(ast: $0)) },
//            source: source,
//            context: self.context
//        )
//        return try tagRenderer.render(tag: tagContext)
//    }

    // Renders a `TemplateConstant` to future `TemplateData`.
    private func render(constant: TemplateConstant, source: TemplateSource) throws -> TemplateData {
        switch constant {
        case .bool(let bool): return .bool(bool)
        case .double(let double): return .double(double)
        case .int(let int): return .int(int)
        case .string(let string): return .string(string)
        case .interpolated(let ast): return try .string(self.serialize(ast: ast))
        }
    }

    // Renders an infix `TemplateExpression` to future `TemplateData`.
    private func render(
        infix: TemplateExpression.InfixOperator,
        left: TemplateSyntax,
        right: TemplateSyntax,
        source: TemplateSource
    ) throws -> TemplateData {
        let left = try self.render(syntax: left)
        let right = try self.render(syntax: right)
        switch infix {
        case .equal: return .bool(left == right)
        case .notEqual: return .bool(left != right)
        case .and: return .bool(left.isTruthy && right.isTruthy)
        case .or: return .bool(left.isTruthy || right.isTruthy)
        default:
            if let a = left.asInt, let b = right.asInt {
                // integer math
                switch infix {
                case .add: return .int(a + b)
                case .subtract: return .int(a - b)
                case .multiply: return .int(a * b)
                case .divide: return .int(a / b)
                case .modulo: return .int(a % b)
                case .greaterThan: return .bool(a > b)
                case .lessThan: return .bool(a < b)
                default: return .null
                }
            } else if let a = left.asDouble, let b = right.asDouble {
                switch infix {
                case .add: return .double(a + b)
                case .subtract: return .double(a - b)
                case .multiply: return .double(a * b)
                case .divide: return .double(a / b)
                case .modulo: return .double(a.truncatingRemainder(dividingBy: b))
                case .greaterThan: return .bool(a > b)
                case .lessThan: return .bool(a < b)
                default: return .null
                }
            } else {
                return .null
            }
        }
    }

    // Renders an prefix `TemplateExpression` to future `TemplateData`.
    private func render(
        prefix: TemplateExpression.PrefixOperator,
        right: TemplateSyntax,
        source: TemplateSource
    ) throws -> TemplateData {
        let right = try render(syntax: right)
        switch prefix {
        case .not: return .bool(!right.isTruthy)
        }
    }

    // Renders `TemplateConditional` to future `TemplateData`.
    private func render(conditional: TemplateConditional, source: TemplateSource) throws -> TemplateData {
        let data = try self.render(syntax: conditional.condition)
    
        if data.isTruthy {
            return try .array(self.render(ast: conditional.body))
        } else if let next = conditional.next {
            return try self.render(conditional: next, source: source)
        } else {
            return .null
        }
    }

    // Renders `TemplateEmbed` to future `TemplateData`.
    private func render(embed: TemplateEmbed, source: TemplateSource) throws -> TemplateData {
        throw TemplateKitError(identifier: "embed", reason: "Only top-level embed is supported.")
    }


    // Renders `TemplateIterator` to future `TemplateData`.
    private func render(iterator: TemplateIterator, source: TemplateSource) throws -> TemplateData {
        guard case .string(let key) = try self.render(syntax: iterator.key) else {
            throw TemplateKitError(
                identifier: "iteratorKey",
                reason: "Could not convert iterator key to string.",
                source: source
            )
        }
        guard case .array(let data) = try self.render(syntax: iterator.data) else {
            throw TemplateKitError(
                identifier: "iteratorData",
                reason: "Could not convert iterator data to array.",
                source: source
            )
        }

        var res = ""
        for (i, item) in data.enumerated() {
            var copy = self.context.data
            copy[key] = item
            copy["index"] = .int(i)
            copy["isFirst"] = .bool(i == 0)
            copy["isLast"] = .bool(i == data.count - 1)
            let serializer = TemplateSerializer(context: .init(data: copy))
            res += try serializer.serialize(ast: iterator.body)
        }
        return .string(res)
    }
}
