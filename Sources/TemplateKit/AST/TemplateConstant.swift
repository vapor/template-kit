/// Supported constant values. These can be thought of as `TemplateIdentifier` that do
/// not need to be resolved.
public enum TemplateConstant: CustomStringConvertible {
    /// A `Bool`.
    ///
    ///     true
    ///
    case bool(Bool)

    /// An `Int`.
    ///
    ///     42
    ///
    case int(Int)

    /// A `Double`.
    ///
    ///     3.14
    ///
    case double(Double)

    /// A `String`.
    ///
    ///     "hello"
    ///
    case string(String)

    /// An interpolated `String` value.
    ///
    ///     "hello \(name)"
    ///
    case interpolated([TemplateSyntax])

    /// See `CustomStringConvertible`.
    public var description: String {
        switch self {
        case .bool(let bool): return bool.description
        case .double(let double): return double.description
        case .int(let int): return int.description
        case .string(let string): return string
        case .interpolated(let ast): return "(" + ast.map { $0 .description }.joined(separator: ", ") + ")"
        }
    }
}
