import Async

public final class Count: TagRenderer {
    init() {}
    
    public func render(tag parsed: TagContext) throws -> Future<TemplateData> {
        let promise = parsed.container.eventLoop.newPromise(TemplateData.self)
        try parsed.requireParameterCount(1)
        
        switch parsed.parameters[0] {
        case .dictionary(let dict):
            promise.succeed(result: .int(dict.values.count))
        case .array(let arr):
            promise.succeed(result: .int(arr.count))
        default:
            promise.succeed(result: .null)
        }

        return promise.futureResult
    }
}

