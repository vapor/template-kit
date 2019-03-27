import Async
import Dispatch
import TemplateKit
import XCTest

class TemplateDataEncoderTests: XCTestCase {
    func testString() {
        let data = "hello"
        try XCTAssertEqual(TemplateDataEncoder().testEncode(data), .string(data))
    }

    func testDouble() {
        let data: Double = 3.14
        try XCTAssertEqual(TemplateDataEncoder().testEncode(data), .double(data))
    }
    
    func testDictionary() {
        let data: [String: String] = ["string": "hello", "foo": "3.14"]
        try XCTAssertEqual(TemplateDataEncoder().testEncode(data), .dictionary([
            "string": .string("hello"),
            "foo": .string("3.14")
        ]))
    }

    func testNestedDictionary() {
        let data: [String: [String: String]] = [
            "a": ["string": "hello", "foo": "3.14"],
            "b": ["greeting": "hey", "foo": "3.15"]
        ]
        try XCTAssertEqual(TemplateDataEncoder().testEncode(data), .dictionary([
        "a": .dictionary([
            "string": .string("hello"),
            "foo": .string("3.14")
            ]),
        "b": .dictionary([
            "greeting": .string("hey"),
            "foo": .string("3.15")
            ])
        ]))
    }

    func testArray() {
        let data: [String] = ["string", "hello", "foo", "3.14"]
        try XCTAssertEqual(TemplateDataEncoder().testEncode(data), .array([
            .string("string"), .string("hello"), .string("foo"), .string("3.14")
        ]))
    }

    func testNestedArray() {
        let data: [[String]] = [["string"], ["hello", "foo"], ["3.14"]]
        try XCTAssertEqual(TemplateDataEncoder().testEncode(data), .array([
            .array([.string("string")]), .array([.string("hello"), .string("foo")]), .array([.string("3.14")])
        ]))
    }

    func testEncodable() {
        struct Hello: Encodable { var hello = "hello" }
        try XCTAssertEqual(TemplateDataEncoder().testEncode(Hello()), .dictionary([
            "hello": .string("hello"),
        ]))
    }

    func testComplexEncodable() {
        struct Test: Encodable {
            var string: String = "hello"
            var double: Double = 3.14
            var int: Int = 42
            var float: Float = -0.5
            var bool: Bool = true
            var fib: [Int] = [0, 1, 1, 2, 3, 5, 8, 13]
        }

        try XCTAssertEqual(TemplateDataEncoder().testEncode(Test()), .dictionary([
            "string": .string("hello"),
            "double": .double(3.14),
            "int": .int(42),
            "float": .double(-0.5),
            "bool": .bool(true),
            "fib": .array([.int(0), .int(1), .int(1), .int(2), .int(3), .int(5), .int(8), .int(13)]),
        ]))
    }

    func testNestedEncodable() {
        final class Test: Encodable {
            var string: String = "hello"
            var double: Double = 3.14
            var int: Int = 42
            var float: Float = -0.5
            var bool: Bool = true
            var sub: Test?
            init(sub: Test? = nil) {
                self.sub = sub
            }
        }

        let sub = Test()
        try XCTAssertEqual(TemplateDataEncoder().testEncode(Test(sub: sub)), .dictionary([
            "string": .string("hello"),
            "double": .double(3.14),
            "int": .int(42),
            "float": .double(-0.5),
            "bool": .bool(true),
            "sub": .dictionary([
                "string": .string("hello"),
                "double": .double(3.14),
                "int": .int(42),
                "float": .double(-0.5),
                "bool": .bool(true),
            ])
        ]))
    }

    func testGH10() throws {
        func wrap(_ syntax: TemplateSyntaxType) -> TemplateSyntax {
            return TemplateSyntax(type: syntax, source: TemplateSource(file: "test", line: 0, column: 0, range: 0..<1))
        }
        func raw(_ string: String) -> TemplateSyntax {
            let data = string.data(using: .utf8) ?? .init()
            return wrap(.raw(TemplateRaw(data: data)))
        }

        let path: [CodingKey] = [
            BasicKey.init("currentUser"),
            BasicKey.init("name"),
        ]

        let ast: [TemplateSyntax] = [
            raw("""
            head
            """),
            wrap(.tag(TemplateTag(
                name: "print",
                parameters: [wrap(.identifier(TemplateIdentifier(path: path)))],
                body: nil
            ))),
            raw("""
            tail
            """),
        ]
        let worker = EmbeddedEventLoop()

        struct User: Codable {
            var id: Int?
            var name: String
        }

        struct Profile: Encodable {
            var currentUser: Future<User>
        }

        let user = User(id: nil, name: "Vapor")
        let profile = Profile(currentUser: Future.map(on: worker) { user })

        let data = try TemplateDataEncoder().testEncode(profile)
        print(data)
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: worker)

        let renderer = PlaintextRenderer(viewsDir: "/", on: container)
        renderer.tags["print"] = Print()

        let view = try TemplateSerializer(
            renderer: renderer,
            context: TemplateDataContext(data: data),
            using: container
        ).serialize(ast: ast).wait()
        XCTAssertEqual(String(data: view.data, encoding: .utf8), "headVaportail")
    }
    
    // https://github.com/vapor/template-kit/issues/20
    func testGH20() throws {
        func wrap(_ syntax: TemplateSyntaxType) -> TemplateSyntax {
            return TemplateSyntax(type: syntax, source: TemplateSource(file: "test", line: 0, column: 0, range: 0..<1))
        }
        
        let path: [CodingKey] = [
            BasicKey.init("date"),
        ]

        let worker = EmbeddedEventLoop()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: worker)
        let renderer = PlaintextRenderer(viewsDir: "/", on: container)
        renderer.tags["date"] = DateFormat()
        let ast: [TemplateSyntax] = [
            wrap(.tag(TemplateTag(
                name: "date",
                parameters: [wrap(.identifier(TemplateIdentifier(path: path)))],
                body: nil
            )))
        ]
        let date = Date()
        let data = try TemplateDataEncoder().testEncode(["date": date])
        print(data)
        let view = try TemplateSerializer(
            renderer: renderer,
            context: TemplateDataContext(data: data),
            using: container
        ).serialize(ast: ast).wait()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print(formatter.string(from: date))
        XCTAssertEqual(String(data: view.data, encoding: .utf8), formatter.string(from: date))
    }
    
    func testTemplabeByteScannerPeak() {
        let scanner = TemplateByteScanner(data: Data(), file: "empty")
        
        XCTAssertNil(scanner.peek(by: 0))
        XCTAssertNil(scanner.peek(by: -1))
        XCTAssertNil(scanner.peek(by: 1))
    }

    static var allTests = [
        ("testString", testString),
        ("testDouble", testDouble),
        ("testDictionary", testDictionary),
        ("testNestedDictionary", testNestedDictionary),
        ("testNestedArray", testNestedArray),
        ("testEncodable", testEncodable),
        ("testComplexEncodable", testComplexEncodable),
        ("testNestedEncodable", testNestedEncodable),
        ("testGH10", testGH10),
        ("testGH20", testGH20),
        ("testTemplabeByteScannerPeak", testTemplabeByteScannerPeak),
    ]
}

extension TemplateDataEncoder {
    func testEncode<E>(_ encodable: E) throws -> TemplateData where E: Encodable {
        return try encode(encodable, on: EmbeddedEventLoop()).wait()
    }
}
