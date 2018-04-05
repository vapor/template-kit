/// An expression, like `1 + 2`, `!1`, and `a || b`
public enum TemplateExpression {

    /// a <op> a
    public enum InfixOperator {
        case add
        case subtract
        case lessThan
        case greaterThan
        case multiply
        case divide
        case equal
        case notEqual
        case and
        case or
    }

    /// <op>a
    public enum PrefixOperator {
        case not
    }

    /// a<op>
    public enum PostfixOperator {}
    
    case infix(`operator`: InfixOperator, left: TemplateSyntax, right: TemplateSyntax)
    case prefix(`operator`: PrefixOperator, right: TemplateSyntax)
    case postfix(`operator`: PostfixOperator, left: TemplateSyntax)
}

extension TemplateExpression: CustomStringConvertible {
    public var description: String {
        switch self {
        case .infix(let op, let left, let right): return "\(left) \(op) \(right)"
        case .prefix(let op, let right): return "\(op)\(right)"
        case .postfix(let op, let left): return "\(left)\(op)"
        }
    }
}

