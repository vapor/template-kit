@_exported import Core
@_exported import Service

// FIXME: move to core

public protocol NestedData {
    var dictionary: [String: Self]? { get }
    var array: [Self]? { get }
    init(dictionary: [String: Self])
    init(array: [Self])
}

extension NestedData {
    /// Sets the partial leaf data to a value at the given path.
    public mutating func set(to value: Self, at path: [CodingKey]) {
        set(&self, to: value, at: path)
    }

    /// Returns the value, if one at from the given path.
    public func get(at path: [CodingKey]) -> Self? {
        var child = self
        for seg in path {
            guard let c = child.dictionary?[seg.stringValue] else {
                return nil
            }
            child = c
        }
        return child
    }

    /// Sets mutable leaf input to a value at the given path.
    private func set(_ context: inout Self, to value: Self, at path: [CodingKey]) {
        guard path.count >= 1 else {
            context = value
            return
        }

        let end = path[0]
        var child: Self
        switch path.count {
        case 1:
            child = value
        case 2...:
            if let index = end.intValue {
                let array = context.array ?? []
                if array.count > index {
                    child = array[index]
                } else {
                    child = .init(array: [])
                }
                set(&child, to: value, at: Array(path[1...]))
            } else {
                child = context.dictionary?[end.stringValue] ?? .init(dictionary: [:])
                set(&child, to: value, at: Array(path[1...]))
            }
        default: fatalError("Unreachable")
        }

        if let index = end.intValue {
            if var arr = context.array {
                if arr.count > index {
                    arr[index] = child
                } else {
                    arr.append(child)
                }
                context = .init(array: arr)
            } else {
                context = .init(array: [child])
            }
        } else {
            if var dict = context.dictionary {
                dict[end.stringValue] = child
                context = .init(dictionary: dict)
            } else {
                context = .init(dictionary: [end.stringValue: child])
            }
        }
    }
}
