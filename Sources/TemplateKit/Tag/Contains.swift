import Async

public final class Contains: TagRenderer {
    public init() {}
    public func render(tag parsed: TagContext) throws -> Future<TemplateData> {
        let promise = parsed.container.eventLoop.newPromise(TemplateData.self)

        try parsed.requireParameterCount(2)

        if let array = parsed.parameters[0].array {
            let compare = parsed.parameters[1]
            promise.succeed(result: .bool(array.contains(compare)))
        } else {
            promise.succeed(result: .bool(false))
        }

        return promise.futureResult
    }
}
