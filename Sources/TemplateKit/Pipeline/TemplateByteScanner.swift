import Bits

/// Used to facilitate parsing byte arrays.
public final class TemplateByteScanner {
    /// Path to file being parsed currently. If the bytes being parsed are not from a file on disk,
    /// instead use any string describing where the bytes came from.
    public var file: String

    /// Current byte offset into the file.
    public var offset: Int

    /// Current line offset into the file.
    public var line: Int

    /// Current column offset into the current line.
    public var column: Int

    /// `Data` being scanned.
    public let data: Data

    /// Byte location information
    var pointer: Array<UInt8>.Index

    /// Current buffer.
    var buffer: [UInt8]

    /// Create a new `TemplateByteScanner`.
    ///
    /// - parameters:
    ///     - data: Bytes to scan.
    ///     - file: Path to file bytes were loaded from or description of bytes.
    public init(data: Data, file: String) {
        self.file = file
        self.data = data
        self.buffer = .init(data)
        self.pointer = 0
        self.offset = 0
        self.line = 0
        self.column = 0
    }

    /// Peeks ahead to byte in front of current byte by supplied amount.
    ///
    /// - parameters:
    ///     - amount: Number of bytes to skip.
    /// - returns:
    ///     - Byte requested if not past end of data.
    public func peek(by amount: Int = 0) -> UInt8? {
        guard pointer + amount < buffer.count && pointer + amount >= 0 else {
            return nil
        }
        return buffer[pointer + amount]
    }

    /// Returns current byte and increments byte pointer.
    public func pop() -> UInt8? {
        guard pointer != buffer.count else {
            return nil
        }

        defer {
            pointer += 1
            offset += 1
        }
        let element = buffer[pointer]
        column += 1
        if element == .newLine {
            line += 1
            column = 0
        }
        return element
    }

    /// Calls `pop()`, throwing an error if there are no more bytes.
    @discardableResult
    public func requirePop() throws -> Byte {
        guard let byte = pop() else {
            throw TemplateKitError(identifier: "parse", reason: "Unexpected EOF")
        }
        return byte
    }

    /// Calls `requirePop()` `n` times.
    public func requirePop(n: Int) throws {
        for _ in 0..<n {
            try requirePop()
        }
    }

    /// Returns `true` if the upcoming bytes match the supplied array of bytes.
    public func peekMatches(_ bytes: [Byte]) -> Bool {
        var iterator = bytes.makeIterator()
        var i = 0
        while let next = iterator.next() {
            switch peek(by: i) {
            case next:
                i += 1
                continue
            default:
                return false
            }
        }

        return true
    }
}
