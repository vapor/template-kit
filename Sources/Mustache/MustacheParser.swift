import CodableKit
import Foundation
import TemplateKit

/// Parses template data into an AST following mustache syntax
/// https://mustache.github.io/mustache.5.html
public final class MustacheParser: TemplateParser {
    /// Creates a new `MustacheParser`
    public init() { }

    /// See TemplateParser.parse
    public func parse(template: Data, file: String) throws -> [TemplateSyntax] {
        let scanner = TemplateByteScanner(data: template, file: file)

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
            throw TemplateError.parse(reason: "Invalid tag open", source: makeSource(using: start))
        }

        let parameters: [TemplateSyntax]
        let body: [TemplateSyntax]?

        guard let key = peek() else {
            throw TemplateError.parse(reason: "Unexpected EOF", source: makeSource(using: start))
        }

        switch key {
        case .leftCurlyBracket: fatalError("raw tag")
        case .numberSign: fatalError("section")
        default:
            // normal tag
            try skipWhitespace()
            let id = try parseIdentifier()
            try skipWhitespace()
            parameters = [id]
            body = nil
        }

        let close = try [requirePop(), requirePop()] // }}
        guard close == [.rightCurlyBracket, .rightCurlyBracket] else {
            throw TemplateError.parse(reason: "Invalid tag close", source: makeSource(using: start))
        }

        let tag = TemplateTag(name: "", parameters: parameters, body: body)
        return TemplateSyntax(type: .tag(tag), source: makeSource(using: start))
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
