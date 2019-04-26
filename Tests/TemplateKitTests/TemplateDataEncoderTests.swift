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

    func testEncodeSuperDefaultImplementation() {
        class A: Encodable {
            var foo = "foo"
        }
        class B: A {
            var bar = "bar"
        }
        try XCTAssertEqual(TemplateDataEncoder().testEncode(B()), .dictionary([
            "foo": .string("foo"),
            ]))
    }

    func testEncodeSuperCustomImplementation() {
        class A: Encodable {
            var foo = "foo"

            enum CodingKeys: String, CodingKey {
                case foo
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(foo, forKey: .foo)
            }
        }
        class B: A {
            var bar = "bar"

            enum SubclassCodingKeys: String, CodingKey {
                case bar
            }

            override func encode(to encoder: Encoder) throws {
                // Note: `super` will also call `encoder.container(keyedBy:)`; we want to ensure that the data written
                // by `super` will still be present in the final dictionary.
                try super.encode(to: encoder)
                var container = encoder.container(keyedBy: SubclassCodingKeys.self)
                try container.encode(bar, forKey: .bar)
            }
        }
        
        try XCTAssertEqual(TemplateDataEncoder().testEncode(B()), .dictionary([
            "foo": .string("foo"),
            "bar": .string("bar"),
            ]))
    }

    func testEncodeSuperCustomImplementationWithSuperEncoder1() {
        class A: Encodable {
            var foo = "foo"

            enum CodingKeys: String, CodingKey {
                case foo
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(foo, forKey: .foo)
            }
        }
        class B: A {
            var bar = "bar"

            enum SubclassCodingKeys: String, CodingKey {
                case bar
            }

            override func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: SubclassCodingKeys.self)
                try container.encode(bar, forKey: .bar)
                try super.encode(to: container.superEncoder())
            }
        }

        try XCTAssertEqual(TemplateDataEncoder().testEncode(B()), .dictionary([
            "super": .dictionary(["foo": .string("foo")]),
            "bar": .string("bar"),
            ]))
    }

    func testEncodeSuperCustomImplementationWithSuperEncoder2() {
        class A: Encodable {
            var foo = "foo"

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(foo)
            }
        }
        class B: A {
            var bar = "bar"

            enum CodingKeys: String, CodingKey {
                case bar
            }

            override func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(bar, forKey: .bar)
                try super.encode(to: container.superEncoder())
            }
        }
        try XCTAssertEqual(TemplateDataEncoder().testEncode(B()), .dictionary([
            "super": .string("foo"),
            "bar": .string("bar"),
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
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try! elg.syncShutdownGracefully() }
        let worker = elg.next()

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
    
    private func checkDateFormatting(
        dateFormat: DateFormat, dateFormatter: DateFormatter, file: StaticString = #file, line: UInt = #line) throws {
        func wrap(_ syntax: TemplateSyntaxType) -> TemplateSyntax {
            return TemplateSyntax(type: syntax, source: TemplateSource(file: "test", line: 0, column: 0, range: 0..<1))
        }

        let path: [CodingKey] = [
            BasicKey.init("date"),
        ]

        let worker = EmbeddedEventLoop()
        let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: worker)
        let renderer = PlaintextRenderer(viewsDir: "/", on: container)
        renderer.tags["date"] = dateFormat
        let ast: [TemplateSyntax] = [
            wrap(.tag(TemplateTag(
                name: "date",
                parameters: [wrap(.identifier(TemplateIdentifier(path: path)))],
                body: nil
            )))
        ]
        let date = Date()
        let data = try TemplateDataEncoder().testEncode(["date": date])
        let view = try TemplateSerializer(
            renderer: renderer,
            context: TemplateDataContext(data: data),
            using: container
        ).serialize(ast: ast).wait()
        XCTAssertEqual(String(data: view.data, encoding: .utf8), dateFormatter.string(from: date), file: file, line: line)
    }
    
    // https://github.com/vapor/template-kit/issues/20
    func testGH20() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        try checkDateFormatting(dateFormat: DateFormat(), dateFormatter: dateFormatter)
    }

    func testISO8601DateFormat() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        try checkDateFormatting(dateFormat: .iso8601, dateFormatter: dateFormatter)
    }
    
    func testTemplabeByteScannerPeak() {
        let scanner = TemplateByteScanner(data: Data(), file: "empty")
        
        XCTAssertNil(scanner.peek(by: 0))
        XCTAssertNil(scanner.peek(by: -1))
        XCTAssertNil(scanner.peek(by: 1))
    }
}

// MARK: - Performance
extension TemplateDataEncoderTests {
    private struct ExampleModel: Encodable {
        var id: Int = 1
        
        var string1: String = "a"
        var string2: String = String(repeating: "b", count: 5)
        var string3: String = String(repeating: "abcdef", count: 2)
        var string4: String? = String(repeating: "abc1", count: 4)
        var string5: String? = String(repeating: "xyz2", count: 4)
        var string6: String? = String(repeating: "100letters", count: 10)
        
        var emptyString1: String? = nil
        var emptyString2: String? = nil
        var emptyString3: String? = nil
        
        var int1: Int = 1
        var int2: Int = 2
        var int3: Int? = nil
        var int4: UInt8 = 1
        var int5: UInt8 = 2
        var int6: UInt8? = nil
        
        var date1: Date = Date(timeIntervalSince1970: 1546300800)  // Midnight (GMT) April 1st, 2019
        var date2: Date? = Date(timeIntervalSince1970: 1546300800)  // Midnight (GMT) April 1st, 2019
        var date3: Date? = nil
        
        var double1: Double = 1
        var double2: Double? = 2
        var double3: Double? = nil
        
        var data1: Data = Data(repeating: 1, count: 16)
        var data2: Data = Data(repeating: 1, count: 32)
        var data3: Data? = Data(repeating: 2, count: 200)
        
        var uuid: UUID = UUID()
    }
    
    private struct Wrapper<E: Encodable>: Encodable {
        var wrapped: E
        
        init(_ wrapped: E) { self.wrapped = wrapped }
    }
    
    private static let exampleModelTestArray = Wrapper(Wrapper(Wrapper(Array(repeating: ExampleModel(), count: 500))))

    func testEncodingPerformanceExampleModelJSONBaseline() throws {
        // Used as a baseline to compare `testEncodingPerformanceExampleModel` against.
        measure {
            _ = try! JSONEncoder().encode(TemplateDataEncoderTests.exampleModelTestArray)
        }
    }
    
    func testEncodingPerformanceExampleModel() throws {
        measure {
            _ = try! TemplateDataEncoder().testEncode(TemplateDataEncoderTests.exampleModelTestArray)
        }
    }
}

extension TemplateDataEncoderTests {
    static var allTests = [
        ("testString", testString),
        ("testDouble", testDouble),
        ("testDictionary", testDictionary),
        ("testNestedDictionary", testNestedDictionary),
        ("testNestedArray", testNestedArray),
        ("testEncodable", testEncodable),
        ("testComplexEncodable", testComplexEncodable),
        ("testNestedEncodable", testNestedEncodable),
        ("testEncodeSuperDefaultImplementation", testEncodeSuperDefaultImplementation),
        ("testEncodeSuperCustomImplementation", testEncodeSuperCustomImplementation),
        ("testEncodeSuperCustomImplementationWithSuperEncoder1", testEncodeSuperCustomImplementationWithSuperEncoder1),
        ("testEncodeSuperCustomImplementationWithSuperEncoder2", testEncodeSuperCustomImplementationWithSuperEncoder2),
        ("testGH10", testGH10),
        ("testGH20", testGH20),
        ("testEncodingPerformanceExampleModelJSONBaseline", testEncodingPerformanceExampleModelJSONBaseline),
        ("testEncodingPerformanceExampleModel", testEncodingPerformanceExampleModel),
        ("testTemplabeByteScannerPeak", testTemplabeByteScannerPeak),
    ]
}

extension TemplateDataEncoder {
    func testEncode<E>(_ encodable: E, on eventLoop: EventLoop = EmbeddedEventLoop()) throws -> TemplateData where E: Encodable {
        return try encode(encodable, on: eventLoop).wait()
    }
}
