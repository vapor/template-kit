import Async
import Dispatch
import Mustache
import TemplateKit
import Service
import XCTest

class MustacheTests: XCTestCase {
    var renderer: MustacheRenderer!

    override func setUp() {
        let worker = try! DefaultEventLoop(label: "codes.vapor.test.mustache")
        let container = BasicContainer(config: .init(), environment: .development, services: .init(), on: worker)
        renderer = MustacheRenderer(using: container)
    }

    func testRaw() {
        let template = "Hello, world!"
        try XCTAssertEqual(renderer.testRender(template, .null), template)
    }

    func testBasic() {
        let template = "Hello, {{name}}!"
        let expected = "Hello, Tanner!"
        try XCTAssertEqual(renderer.testRender(template, .dictionary(["name": .string("Tanner")])), expected)
    }

    func testUnescaped() {
        let template = "Hello, {{{html}}}!"
        let expected = "Hello, Tan&ner!"
        try XCTAssertEqual(renderer.testRender(template, .dictionary(["html": .string("Tan&ner")])), expected)
    }

    func testSection() {
        let template = "{{#cond}}It's true{{/cond}}!"
        let isFalse = "!"
        let isTrue = "It's true!"
        try XCTAssertEqual(renderer.testRender(template, .dictionary(["cond": .bool(false)])), isFalse)
        try XCTAssertEqual(renderer.testRender(template, .dictionary(["cond": .bool(true)])), isTrue)
    }

    static var allTests = [
        ("testRaw", testRaw),
        ("testBasic", testBasic),
        ("testUnescaped", testUnescaped),
        ("testSection", testSection),
    ]
}

extension MustacheRenderer {
    func testRender(_ template: String, _ data: TemplateData) throws -> String {
        let view = try render(template: template.data(using: .utf8)!, data).blockingAwait()
        return String(data: view.data, encoding: .utf8)!
    }
}
