#warning("cleanup encoder")
public struct TemplateContextEncoder {
    /// Create a new `TemplateContextEncoder`.
    public init() {}

    /// Encode an `Encodable` item to `TemplateData`.
    public func encode<E>(_ encodable: E, base: [String: TemplateData]) throws -> [String: TemplateData]
        where E: Encodable
    {
        let encoder = _Encoder(data: base)
        try encodable.encode(to: encoder)
        return encoder.data
    }
    
    private final class _Encoder: Encoder {
        var data: [String: TemplateData]
        
        var codingPath: [CodingKey] {
            return []
        }
        var userInfo: [CodingUserInfoKey: Any] {
            return [:]
        }
        
        init(data: [String: TemplateData]) {
            self.data = data
        }
        
        func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
            return KeyedEncodingContainer(KeyedEncoder<Key>(encoder: self))
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            fatalError("Cannot encode top-level array to TemplateData.")
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            fatalError("Cannot encode top-level value to TemplateData.")
        }
        
        struct KeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
            typealias Key = K
            
            var codingPath: [CodingKey] {
                return []
            }
            var encoder: _Encoder
            
            init(encoder: _Encoder) {
                self.encoder = encoder
            }
            
            func superEncoder() -> Encoder {
                return self.encoder
            }
            
            func encodeNil(forKey key: K) throws {
                self.encoder.data[key.stringValue] = .null
            }
            
            func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
                where NestedKey : CodingKey
            {
                fatalError("TemplateData does not support encoding nested containers.")
            }
            
            func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
                fatalError("TemplateData does not support encoding nested unkeyed containers.")
            }
            
            func superEncoder(forKey key: K) -> Encoder {
                fatalError("TemplateData does not support encoding super encoder.")
            }
            
            func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
                encoder.data[key.stringValue] = try _DataEncoder().encode(value)
            }
        }
    }

    struct _DataEncoder {
        public init() { }
        
        /// Encode an `Encodable` item to `TemplateData`.
        public func encode<E>(_ encodable: E) throws -> TemplateData
            where E: Encodable
        {
            let encoder = _Encoder()
            try encodable.encode(to: encoder)
            if let keyed = encoder.keyed {
                return .dictionary(keyed)
            } else if let unkeyed = encoder.unkeyed {
                return .array(unkeyed)
            } else if let single = encoder.single {
                return single
            } else {
                fatalError("No TemplateData encoded.")
            }
        }
        
        private final class _Encoder: Encoder {
            var keyed: [String: TemplateData]?
            var unkeyed: [TemplateData]?
            var single: TemplateData?
            
            var codingPath: [CodingKey] {
                return []
            }
            var userInfo: [CodingUserInfoKey: Any] {
                return [:]
            }
            
            init() { }
            
            func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
                return KeyedEncodingContainer(KeyedEncoder<Key>(encoder: self))
            }
            
            func unkeyedContainer() -> UnkeyedEncodingContainer {
                return UnkeyedEncoder(encoder: self)
            }
            
            func singleValueContainer() -> SingleValueEncodingContainer {
                return SingleValueEncoder(encoder: self)
            }
            
            struct KeyedEncoder<K>: KeyedEncodingContainerProtocol where K: CodingKey {
                typealias Key = K
                
                var codingPath: [CodingKey] {
                    return []
                }
                var encoder: _Encoder
                
                init(encoder: _Encoder) {
                    self.encoder = encoder
                    self.encoder.keyed = [:]
                }
                
                func superEncoder() -> Encoder {
                    return self.encoder
                }
                
                func encodeNil(forKey key: K) throws {
                    self.encoder.keyed![key.stringValue] = .null
                }
                
                func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
                    where NestedKey : CodingKey
                {
                    fatalError("TemplateData does not support encoding nested containers.")
                }
                
                func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
                    fatalError("TemplateData does not support encoding nested unkeyed containers.")
                }
                
                func superEncoder(forKey key: K) -> Encoder {
                    return self.encoder
                }
                
                func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
                    self.encoder.keyed![key.stringValue] = try _DataEncoder().encode(value)
                }
            }
            
            struct UnkeyedEncoder: UnkeyedEncodingContainer {
                var count: Int
                var codingPath: [CodingKey] {
                    return []
                }
                var encoder: _Encoder
                
                init(encoder: _Encoder) {
                    self.encoder = encoder
                    self.count = 0
                    self.encoder.unkeyed = []
                }
                
                mutating func encodeNil() throws {
                    defer { self.count += 1 }
                    self.encoder.unkeyed!.append(.null)
                }
                
                func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey>
                    where NestedKey: CodingKey
                {
                    fatalError("TemplateData does not support encoding nested containers.")
                }
                
                func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
                    fatalError("TemplateData does not support encoding nested unkeyed containers.")
                }
                
                func superEncoder() -> Encoder {
                    return self.encoder
                }
                
                func encode<T>(_ value: T) throws where T: Encodable {
                    try self.encoder.unkeyed!.append(_DataEncoder().encode(value))
                }
            }
            
            struct SingleValueEncoder: SingleValueEncodingContainer {
                var codingPath: [CodingKey] {
                    return []
                }
                var encoder: _Encoder
                
                init(encoder: _Encoder) {
                    self.encoder = encoder
                }
                
                func superEncoder() -> Encoder {
                    return self.encoder
                }
                
                func encodeNil() throws {
                    self.encoder.single = .null
                }
                
                mutating func encode(_ value: Bool) throws {
                    self.encoder.single = .bool(value)
                }
                
                mutating func encode(_ value: String) throws {
                    self.encoder.single = .string(value)
                }
                
                mutating func encode(_ value: Double) throws {
                    self.encoder.single = .double(value)
                }
                
                mutating func encode(_ value: Float) throws {
                    self.encoder.single = .double(Double(value))
                }
                
                mutating func encode(_ value: Int) throws {
                    self.encoder.single = .int(value)
                }
                
                mutating func encode(_ value: Int8) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: Int16) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: Int32) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: Int64) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: UInt) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: UInt8) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: UInt16) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: UInt32) throws {
                    self.encoder.single = .int(Int(value))
                }
                
                mutating func encode(_ value: UInt64) throws {
                    self.encoder.single = .string(value.description)
                }
                
                func encode<T>(_ value: T) throws where T: Encodable {
                    if let custom = value as? CustomTemplateDataConvertible {
                        self.encoder.single = custom.templateData
                    } else {
                        try value.encode(to: self.encoder)
                    }
                }
            }
        }
    }
}
