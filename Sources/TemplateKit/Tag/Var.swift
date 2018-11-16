/// Sets data to the tag context.
///
///     var(<key>, <item>)
///
/// The second parameter can be either an item or emitted and the tag body will be used.
public final class Var: TagRenderer {
    /// Creates a new `Var` tag renderer.
    public init() {}

    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> TemplateData {
        guard tag.parameters.count >= 1 else {
            throw tag.error(reason: "invalid parameter count")
        }
        
        switch tag.parameters[0] {
        case .string(let key):
            switch tag.parameters.count {
            case 1:
                tag.context.data[key] = try tag.requireBody()
                return .null
            case 2:
                tag.context.data[key] = tag.parameters[1]
                return .null
            default:
                throw tag.error(reason: "invalid parameter count")
            }
        default:
            throw tag.error(reason: "Unsupported key type")
        }
    }
}
