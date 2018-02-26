import CodableKit
import Foundation
import TemplateKit

/// Parses template data into an AST following mustache syntax
/// https://mustache.github.io/mustache.5.html
public final class MustacheParser: TemplateParser {
    /// Creates a new `MustacheParser`
    public init() { }

    /// See TemplateParser.parse
    public func parse(scanner: TemplateByteScanner) throws -> [TemplateSyntax] {
        var ast: [TemplateSyntax] = []
        while let syntax = try scanner.parseSyntax() {
            ast.append(syntax)
        }

        return ast
    }
}

/// MARK: Private

extension TemplateByteScanner {
    /// Parses the next syntax.
    fileprivate func parseSyntax() throws -> TemplateSyntax? {
        guard let first = peek() else { return nil }
        switch first {
        case .leftCurlyBracket:
            guard let second = peek(by: 1) else { return nil }
            switch second {
            case .leftCurlyBracket: return try parseTag()
            default: break
            }
        default: break
        }
        return try parseRaw()
    }

    /// Accumulates view data until a left curly brace is found.
    fileprivate func parseRaw() throws -> TemplateSyntax {
        let start = makeSourceStart()

        parse: while let byte = peek() {
            switch byte {
            case .leftCurlyBracket: break parse
            default: try requirePop()
            }
        }

        let raw = TemplateRaw(data: data[start.offset..<offset])
        return TemplateSyntax(type: .raw(raw), source: makeSource(using: start))
    }

    /// Parses mustache tags.
    /// Calling methods should have ensured the next two bytes are at least `{{`.
    fileprivate func parseTag() throws -> TemplateSyntax {
        let start = makeSourceStart()

        let open = try [requirePop(), requirePop()] // {{
        guard open == [.leftCurlyBracket, .leftCurlyBracket] else {
            throw TemplateError.parse(reason: "Invalid tag open", template: makeSource(using: start), source: .capture())
        }

        let type: TemplateSyntaxType

        guard let key = peek() else {
            throw TemplateError.parse(reason: "Unexpected EOF", template: makeSource(using: start), source: .capture())
        }

        switch key {
        case .leftCurlyBracket:
            // pop extra {
            try requirePop()

            // raw tag
            try skipWhitespace()
            let id = try parseIdentifier()
            try skipWhitespace()

            // pop tag close
            let close = try [requirePop(), requirePop(), requirePop()] // }}}
            guard close == [.rightCurlyBracket, .rightCurlyBracket, .rightCurlyBracket] else {
                throw TemplateError.parse(reason: "Invalid tag close", template: makeSource(using: start), source: .capture())
            }

            let tag = TemplateTag(name: "get", parameters: [id], body: nil)
            type = .tag(tag)
        case .numberSign:
            // pop extra #
            try requirePop()

            // section tag
            try skipWhitespace()
            let id = try parseIdentifier()
            try skipWhitespace()

            // pop tag close
            let close = try [requirePop(), requirePop()] // }}
            guard close == [.rightCurlyBracket, .rightCurlyBracket] else {
                throw TemplateError.parse(reason: "Invalid tag close", template: makeSource(using: start), source: .capture())
            }

            // parse section body
            var body: [TemplateSyntax] = []
            parse: while let syntax = try parseSyntax() {
                switch syntax.type {
                case .tag(let tag):
                    if
                        /// if this is the end tag for this section
                        case .identifier(let a) = tag.parameters[0].type,
                        case .identifier(let b) = id.type,
                        tag.name == "_end",
                        a.path.map({ $0.stringValue }) == b.path.map({ $0.stringValue })
                    {
                        break parse
                    }
                default: body.append(syntax)
                }
            }

            let cond = TemplateConditional(condition: id, body: body, next: nil)
            type = .conditional(cond)
        case .forwardSlash:
            // pop extra /
            try requirePop()

            // section tag
            try skipWhitespace()
            let id = try parseIdentifier()
            try skipWhitespace()

            // pop tag close
            let close = try [requirePop(), requirePop()] // }}
            guard close == [.rightCurlyBracket, .rightCurlyBracket] else {
                throw TemplateError.parse(reason: "Invalid tag close", template: makeSource(using: start), source: .capture())
            }

            let tag = TemplateTag(name: "_end", parameters: [id], body: nil)
            type = .tag(tag)
        default:
            // normal tag
            try skipWhitespace()
            let id = try parseIdentifier()
            try skipWhitespace()

            // pop tag close
            let close = try [requirePop(), requirePop()] // }}
            guard close == [.rightCurlyBracket, .rightCurlyBracket] else {
                throw TemplateError.parse(reason: "Invalid tag close", template: makeSource(using: start), source: .capture())
            }

            let tag = TemplateTag(name: "", parameters: [id], body: nil)
            type = .tag(tag)
        }


        return TemplateSyntax(type: type, source: makeSource(using: start))
    }

    /// Parses identifiers, like `foo.bar.baz`.
    /// Whitespace must be skipped before and after
    fileprivate func parseIdentifier() throws -> TemplateSyntax {
        let start = makeSourceStart()

        while let next = peek(), !next.isWhitespace, (next.isAlphanumeric || next == .period) {
            try requirePop()
        }

        let path = data[start.offset..<offset]
            .split(separator: .period)
            .map { Data($0) }
            .map { String(data: $0, encoding: .utf8) ?? "" }
            .map { BasicKey($0) as CodingKey }

        let id = TemplateIdentifier(path: path)
        return TemplateSyntax(type: .identifier(id), source: makeSource(using: start))
    }

    fileprivate func skipWhitespace() throws {
        while let next = peek(), next.isWhitespace {
            try requirePop()
        }
    }
}
