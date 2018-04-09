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
        var dict = tag.context.data.dictionary ?? [:]
        switch tag.parameters.count {
        case 1:
            let body = try tag.requireBody()
            guard let key = tag.parameters[0].string else {
                throw tag.error(reason: "Unsupported key type")
            }

            let data = tag.serializer.serialize(ast: body).map(to: TemplateData.self) { view in
                dict[key] = .data(view.data)
                tag.context.data = .dictionary(dict)
                return .null
            }
            return .future(data)
        case 2:
            guard let key = tag.parameters[0].string else {
                throw tag.error(reason: "Unsupported key type")
            }
            dict[key] = tag.parameters[1]
            tag.context.data = .dictionary(dict)
            return .null
        default:
            try tag.requireParameterCount(2)
            return .null
        }
    }
}
