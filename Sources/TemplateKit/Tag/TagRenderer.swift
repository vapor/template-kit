import Async
import Foundation

public protocol TagRenderer {
    func render(tag: TagContext) throws -> TemplateData
}

// MARK: Global

public var defaultTags: [String: TagRenderer] {
    return [
        "": Print(),
        "contains": Contains(),
        "lowercase": Lowercase(),
        "uppercase": Uppercase(),
        "capitalize": Capitalize(),
        "count": Count(),
        "set": Var(),
        "get": Raw(),
        "date": DateFormat()
    ]
}
