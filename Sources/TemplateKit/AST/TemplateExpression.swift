/// An infix, prefix, or postfix expression, e.g., `1 + 2`, `!1`, and `a || b`.
public enum TemplateExpression: CustomStringConvertible {
    /// An operator in an infix epxression.
    ///
    ///     a <op> b
    ///
    public enum InfixOperator: CustomStringConvertible {
        /// Adds the left and right values.
        ///
        ///     a + b
        ///
        case add

        /// Subtracts the right value from the left value.
        ///
        ///     a - b
        ///
        case subtract

        /// Multiplies the left and right values.
        ///
        ///     a * b
        ///
        case multiply

        /// Divids the left value by the right value.
        ///
        ///     a / b
        ///
        case divide

        /// Checks whether the left value is less than the right value.
        ///
        ///     a < b
        ///
        case lessThan

        /// Checks whether the left value is greater than the right value.
        ///
        ///     a > b
        ///
        case greaterThan

        /// Checks whether the left value is less than or equal to the right value.
        ///
        ///     a <= b
        ///
        case lessThanOrEqual

        /// Checks whether the left value is greater than or equal to the right value.
        ///
        ///     a >= b
        ///
        case greaterThanOrEqual

        /// Checks whether the left and right values are equal.
        ///
        ///     a == b
        ///
        case equal

        /// Checks whether the left and right values are not equal.
        ///
        ///     a != b
        ///
        case notEqual

        /// Checks whether the left and right values are truthy.
        ///
        ///     a && b
        ///
        case and

        /// Checks whether the left or right value is truthy.
        ///
        ///     a || b
        ///
        case or

        /// See `CustomStringConvertible`.
        public var description: String {
            switch self {
            case .add: return "+"
            case .subtract: return "-"
            case .multiply: return "*"
            case .divide: return "/"
            case .lessThan: return "<"
            case .greaterThan: return ">"
            case .lessThanOrEqual: return "<="
            case .greaterThanOrEqual: return ">="
            case .equal: return "=="
            case .notEqual: return "!="
            case .and: return "&&"
            case .or: return "||"
            }
        }
    }

    /// An operator in an prefix epxression.
    ///
    ///     <op> a
    ///
    public enum PrefixOperator: CustomStringConvertible {
        /// Checks whether the value is not truthy.
        ///
        ///     !a
        ///
        case not

        /// See `CustomStringConvertible`.
        public var description: String {
            switch self {
            case .not: return "!"
            }
        }
    }


    /// An operator in an prefix epxression.
    ///
    ///     a <op>
    ///
    public enum PostfixOperator: CustomStringConvertible {
        /// No postfix operators yet.

        /// See `CustomStringConvertible`.
        public var description: String {
            switch self { }
        }
    }

    /// An `InfixOperator` with left and right `TemplateSyntax` values.
    case infix(op: InfixOperator, left: TemplateSyntax, right: TemplateSyntax)

    /// A `PrefixOperator` with `TemplateSyntax` value.
    case prefix(op: PrefixOperator, right: TemplateSyntax)

    /// A `PostfixOperator` with `TemplateSyntax` value.
    case postfix(op: PostfixOperator, left: TemplateSyntax)

    /// See `CustomStringConvertible`.
    public var description: String {
        switch self {
        case .infix(let op, let left, let right): return "\(left) \(op) \(right)"
        case .prefix(let op, let right): return "\(op)\(right)"
        case .postfix(let op, let left): return "\(left)\(op)"
        }
    }
}
