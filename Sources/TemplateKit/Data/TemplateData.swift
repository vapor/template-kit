/// TemplateKit's supported serializable data types.
/// - note: This is different from types supported in the AST.
public enum TemplateData: Equatable, CustomTemplateDataConvertible {
    /// A `Bool`.
    ///
    ///     true
    ///
    case bool(Bool)
    
    /// A `String`.
    ///
    ///     "hello"
    ///
    case string(String)
    
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
    
    /// A nestable `[String: TemplateData]` dictionary.
    case dictionary([String: TemplateData])
    
    /// A nestable `[TemplateData]` array.
    case array([TemplateData])
    
    /// Null.
    case null
    
    /// Returns true if the value is not equal to a "falsey" value (0, false, empty array, etc)
    public var isTruthy: Bool {
        switch self {
        case .bool(let bool): return bool
        case .string(let string):
            switch string {
            case "0", "false", "no": return false
            default: return true
            }
        case .int(let int):
            return int != 0
        case .double(let double):
            return double != 0
        case .null: return false
        case .dictionary(let dict): return !dict.isEmpty
        case .array(let arr): return !arr.isEmpty
        }
    }
    
    public var asInt: Int? {
        switch self {
        case .bool(let bool): return bool ? 1 : 0
        case .string(let string): return Int(string)
        case .int(let int): return int
        default: return nil
        }
    }
    
    public var asDouble: Double? {
        switch self {
        case .bool(let bool): return bool ? 1 : 0
        case .string(let string): return Double(string)
        case .int(let int): return Double(int)
        case .double(let double): return double
        default: return nil
        }
    }
    
    public func get(at path: [String]) -> TemplateData? {
        var data: TemplateData = self
        for segment in path {
            switch data {
            case .dictionary(let dict):
                if let next = dict[segment] {
                    data = next
                } else {
                    return nil
                }
            default: return nil
            }
        }
        return data
    }
    
    /// See `CustomTemplateDataConvertible`.
    public var templateData: TemplateData {
        return self
    }
}
