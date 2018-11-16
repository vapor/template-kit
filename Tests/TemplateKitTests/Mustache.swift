import NIO
import TemplateKit

public final class MustacheRenderer: TemplateRenderer, TemplateParser {
    public var tags: [String : TagRenderer] {
        fatalError()
    }
    
    public var parser: TemplateParser {
        return self
    }
    
    public var astCache: ASTCache?
    
    public var templateFileEnding: String {
        return ".mustache"
    }
    
    public var relativeDirectory: String
    
    public var baseContext: [String : TemplateData]
    
    public var fileIO: NonBlockingFileIO
    
    public var eventLoop: EventLoop
    
    public init(relativeDirectory: String, fileIO: NonBlockingFileIO, on eventLoop: EventLoop) {
        self.relativeDirectory = relativeDirectory
        self.fileIO = fileIO
        self.eventLoop = eventLoop
        self.baseContext = [:]
    }
    
    public func parse(scanner: TemplateScanner) throws -> [TemplateSyntax] {
        let parser = MustacheParser(scanner: scanner)
        var ast: [TemplateSyntax] = []
        while let syntax = try parser.parseSyntax() {
            ast.append(syntax)
        }
        return ast
    }
}

struct MustacheParser {
    var scanner: TemplateScanner
    
    func parseSyntax() throws -> TemplateSyntax? {
        print(#function)
        guard let first = scanner.peek() else {
            return nil
        }
        print(first)
        switch first {
        case .leftCurlyBracket:
            guard let second = scanner.peek(by: 1) else {
                return nil
            }
            switch second {
            case .leftCurlyBracket: return try parseTag()
            default: return try parseRaw()
            }
        default: return try parseRaw()
        }
    }
    
    func parseTag() throws -> TemplateSyntax? {
        print(#function)
        let start = self.scanner.makeSourceStart()
        guard let _ = self.scanner.pop(), let _ = self.scanner.pop() else {
            return nil
        }
        
        skipSpaces()
        
        guard let id = try self.parseIdentifier() else {
            return nil
        }
        
        skipSpaces()
        #warning("FIXME: verify }}")
        guard let _ = self.scanner.pop(), let _ = self.scanner.pop() else {
            return nil
        }
        
        return TemplateSyntax(type: .identifier(id), source: self.scanner.makeSource(using: start))
        
    }
    
    func parseIdentifier() throws -> TemplateIdentifier? {
        print(#function)
        guard let space = self.scanner.find(.space) else {
            return nil
        }
        return self.scanner.data.readString(length: space).flatMap { string in
            return TemplateIdentifier(path: string.split(separator: ".").map(String.init))
        }
    }
    
    func skipSpaces() {
        print(#function)
        while true {
            if scanner.peek() == .space {
                _ = scanner.pop()
            } else {
                break
            }
        }
    }
    
    func parseRaw() throws -> TemplateSyntax? {
        print(#function)
        let start = scanner.makeSourceStart()
        
        var length: Int
        if let nextTag = self.scanner.find(.leftCurlyBracket) {
            length = nextTag
        } else {
            length = self.scanner.data.readableBytes
        }
        print("length: \(length)")
        guard let data = scanner.data.readSlice(length: length) else {
            return nil
        }
        return TemplateSyntax(
            type: .raw(.init(data: data)),
            source: scanner.makeSource(using: start)
        )
    }
}

extension  UInt8 {
    static let leftCurlyBracket: UInt8 = 0x7B
    static let space: UInt8 = 0x20
}
