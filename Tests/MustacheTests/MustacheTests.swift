import Async
import Dispatch
import Mustache
import TemplateKit
import XCTest

class MustacheTests: XCTestCase {
    var renderer: MustacheRenderer!

    override func setUp() {
        let worker = try! DefaultEventLoop(label: "codes.vapor.test.mustache")
        renderer = MustacheRenderer(on: worker)
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

    static var allTests = [
        ("testRaw", testRaw),
        ("testBasic", testBasic),
    ]
}

extension MustacheRenderer {
    func testRender(_ template: String, _ data: TemplateData) throws -> String {
        let view = try render(template: template.data(using: .utf8)!, data).blockingAwait()
        return String(data: view.data, encoding: .utf8)!
    }
}
