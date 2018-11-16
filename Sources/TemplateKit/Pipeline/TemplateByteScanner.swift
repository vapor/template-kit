import NIO

/// Used to facilitate parsing byte arrays.
public final class TemplateScanner {
    /// Path to file being parsed currently. If the bytes being parsed are not from a file on disk,
    /// instead use any string describing where the bytes came from.
    public var file: String

    /// Current column offset into the current line.
    public var start: Int

    /// `Data` being scanned.
    public var data: ByteBuffer
    
    /// Create a new `TemplateByteScanner`.
    ///
    /// - parameters:
    ///     - data: Bytes to scan.
    ///     - file: Path to file bytes were loaded from or description of bytes.
    public init(data: ByteBuffer, file: String) {
        self.file = file
        self.data = data
        self.start = data.readerIndex
    }
    
    public func peek(by n: Int = 0) -> UInt8? {
        guard self.data.readableBytes > 0 else {
            return nil
        }
        return self.data.getInteger(at: self.data.readerIndex + n)
    }
    
    public func pop() -> UInt8? {
        return self.data.readInteger()
    }
    
    public func find(_ byte: UInt8) -> Int? {
        var i = 0
        while true {
            defer { i += 1 }
            guard let next = self.peek(by: i) else {
                return nil
            }
            if next == byte {
                return i
            }
        }
    }
}
