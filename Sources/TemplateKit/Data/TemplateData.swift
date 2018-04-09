/// TemplateKit's supported serializable data types.
/// - note: This is different from types supported in the AST.
public enum TemplateData: NestedData, Equatable {
    // MARK: Equatable

    /// See `Equatable`.
    public static func ==(lhs: TemplateData, rhs: TemplateData) -> Bool {
        /// Fuzzy compare
        if lhs.string != nil && lhs.string == rhs.string {
            return true
        } else if lhs.int != nil && lhs.int == rhs.int {
            return true
        } else if lhs.double != nil && lhs.double == rhs.double {
            return true
        } else if lhs.bool != nil && lhs.bool == rhs.bool {
            return true
        }

        /// Strict compare
        switch (lhs, rhs) {
        case (.array(let a), .array(let b)): return a == b
        case (.dictionary(let a), .dictionary(let b)): return a == b
        case (.bool(let a), .bool(let b)): return a == b
        case (.string(let a), .string(let b)): return a == b
        case (.int(let a), .int(let b)): return a == b
        case (.double(let a), .double(let b)): return a == b
        case (.data(let a), .data(let b)): return a == b
        case (.null, .null): return true
        default: return false
        }
    }

    // MARK: Cases

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

    /// `Data` blob.
    ///
    ///     Data([0x72, 0x73])
    ///
    case data(Data)

    /// A nestable `[String: TemplateData]` dictionary.
    case dictionary([String: TemplateData])

    /// A nestable `[TemplateData]` array.
    case array([TemplateData])

    /// A lazily-resolvable `TemplateData`.
    case lazy(() -> (TemplateData))

    /// Null.
    case null

    // MARK: Nested Data

    /// See `NestedData`.
    public init(array: [TemplateData]) {
        self = .array(array)
    }

    /// See `NestedData`.
    public init(dictionary: [String: TemplateData]) {
        self = .dictionary(dictionary)
    }

    // MARK: Fuzzy

    /// Attempts to convert to `String` or returns `nil`.
    public var string: String? {
        switch self {
        case .bool(let bool):
            return bool.description
        case .double(let double):
            return double.description
        case .int(let int):
            return int.description
        case .string(let s):
            return s
        case .data(let d):
            return String(data: d, encoding: .utf8)
        case .lazy(let lazy):
            return lazy().string
        default:
            return nil
        }
    }

    /// Attempts to convert to `Bool` or returns `nil`.
    public var bool: Bool? {
        switch self {
        case .int(let i):
            switch i {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case .double(let d):
            switch d {
            case 1:
                return true
            case 0:
                return false
            default:
                return nil
            }
        case .string(let s):
            return Bool(s)
        case .bool(let b):
            return b
        case .lazy(let lazy):
            return lazy().bool
        default:
            return nil
        }
    }

    /// Attempts to convert to `Double` or returns `nil`.
    public var double: Double? {
        switch self {
        case .int(let i):
            return Double(i)
        case .double(let d):
            return d
        case .string(let s):
            return Double(s)
        case .lazy(let lazy):
            return lazy().double
        default:
            return nil
        }
    }

    /// Attempts to convert to `Int` or returns `nil`.
    public var int: Int? {
        switch self {
        case .int(let i):
            return i
        case .string(let s):
            return Int(s)
        case .lazy(let lazy):
            return lazy().int
        default:
            return nil
        }
    }

    /// Attempts to convert to `[String: TemplateData]` or returns `nil`.
    public var dictionary: [String: TemplateData]? {
        switch self {
        case .dictionary(let d):
            return d
        default:
            return nil
        }
    }

    /// Attempts to convert to `[TemplateData]` or returns `nil`.
    public var array: [TemplateData]? {
        switch self {
        case .array(let a):
            return a
        default:
            return nil
        }
    }

    /// Attempts to convert to `Data` or returns `nil`.
    public var data: Data? {
        switch self {
        case .data(let d):
            return d
        case .string(let s):
            return s.data(using: .utf8)
        case .lazy(let lazy):
            return lazy().data
        case .int(let i):
            return i.description.data(using: .utf8)
        case .array(let arr):
            var data = Data()
            
            for i in arr {
                switch i {
                case .null: break
                default:
                    guard let u = i.data else {
                        return nil
                    }

                    data += u
                }
            }

            return data
        default:
            return nil
        }
    }

    /// Returns `true` if the data is `null`.
    public var isNull: Bool {
        switch self {
        case .null: return true
        default: return false
        }
    }
}
