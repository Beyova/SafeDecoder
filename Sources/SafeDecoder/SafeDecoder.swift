//
//  SafeDecoder.swift
//  SafeDecoder
//
//  Created by canius.chu on 2020/1/5.
//  Copyright © 2020 Beyova. All rights reserved.
//

import Foundation

public protocol SafeDecodable: Decodable {
    
    init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) throws
    
    init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer) throws
    
    init?(fallbackFrom string: String)
}

public typealias FallbackValue = (fallback: Bool, value: Any?)

public protocol FallbackCodingKey: CodingKey {
    
    func fallbackValue() -> FallbackValue
}

// MARK: - SafeDecodable Impl

public extension SafeDecodable {

    init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) throws {
        if case DecodingError.typeMismatch(_, _) = error {
            let string = try container.decode(String.self, forKey: key)
            if let val =  Self(fallbackFrom: string) {
                self = val
                return
            }
        }
        throw error
    }
    
    init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer) throws {
        if case DecodingError.typeMismatch(_, _) = error {
            let string = try container.decode(String.self)
            if let val = Self(fallbackFrom: string) {
                self = val
                return
            }
        }
        throw error
    }
}

extension Date: SafeDecodable {

    public init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: K) throws {
        if case DecodingError.dataCorrupted(_) = error {
            let string = try container.decode(String.self, forKey: key)
            if string.isEmpty { return nil }
        }
        throw error
    }
    
    public init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer) throws {
        if case DecodingError.dataCorrupted(_) = error {
            let string = try container.decode(String.self)
            if string.isEmpty { return nil }
        }
        throw error
    }
    
    public init?(fallbackFrom string: String) { return nil }
}

extension Bool: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        switch string.lowercased() {
        case "true": self = true
        case "false": self = false
        default: return nil
        }
    }
}

extension Double: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Double(string) else { return nil }
        self = val
    }
}

extension Float: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Float(string) else { return nil }
        self = val
    }
}

extension Int: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Int(string) else { return nil }
        self = val
    }
}

extension Int8: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Int8(string) else { return nil }
        self = val
    }
}

extension Int16: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Int16(string) else { return nil }
        self = val
    }
}

extension Int32: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Int32(string) else { return nil }
        self = val
    }
}

extension Int64: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = Int64(string) else { return nil }
        self = val
    }
}

extension UInt: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = UInt(string) else { return nil }
        self = val
    }
}

extension UInt8: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = UInt8(string) else { return nil }
        self = val
    }
}

extension UInt16: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = UInt16(string) else { return nil }
        self = val
    }
}

extension UInt32: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = UInt32(string) else { return nil }
        self = val
    }
}

extension UInt64: SafeDecodable {
    
    public init?(fallbackFrom string: String) {
        guard let val = UInt64(string) else { return nil }
        self = val
    }
}

extension Array: SafeDecodable where Element: SafeDecodable {

    public init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: K) throws {
        if case DecodingError.typeMismatch(_, _) = error {
            var unkeyed = try container.nestedUnkeyedContainer(forKey: key)
            var array = [Element]()
            while !unkeyed.isAtEnd {
                array.append(try Element.decode(by: &unkeyed))
            }
            self = array
            return
        }
        throw error
    }
    
    public init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer) throws {
        if case DecodingError.typeMismatch(_, _) = error {
            var unkeyed = try container.nestedUnkeyedContainer()
            var array = [Element]()
            while !unkeyed.isAtEnd {
                array.append(try Element.decode(by: &unkeyed))
            }
            self = array
            return
        }
        throw error
    }
    
    public init?(fallbackFrom string: String) { return nil }
}

// MARK: - Enum

public extension KeyedDecodingContainer {
    
    func decode<T: RawRepresentable & Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T where T.RawValue == String {
        do {
            return try origin_decode(type, forKey: key)
        } catch let error as DecodingError {
            return try key.fallbackFrom(error: error)
        }
    }
    
    func decodeIfPresent<T: RawRepresentable & Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T? where T.RawValue == String {
        do {
            return try origin_decodeIfPresent(type, forKey: key)
        } catch let error as DecodingError {
            if case DecodingError.dataCorrupted(_) = error {
                do {
                    if let string = try decodeIfPresent(String.self, forKey: key), !string.isEmpty {
                        print("unknown enum value: \(string) error: \(error)")
                    }
                    return nil
                } catch {}
                return try key.fallbackFrom(error: error)
            }
            throw error
        }
    }
    
    func decode<T: RawRepresentable & Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T where T.RawValue: SafeDecodable {
        do {
            return try origin_decode(type, forKey: key)
        } catch let error as DecodingError {
            if case DecodingError.typeMismatch(_, _) = error {
                do {
                    let rawValue = try T.RawValue.decode(by: self, forKey: key, fallback: false)
                    if let result = T(rawValue: rawValue) {
                        return result
                    }
                } catch {}
            }
            return try key.fallbackFrom(error: error)
        }
    }
    
    func decodeIfPresent<T: RawRepresentable & Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T? where T.RawValue: SafeDecodable {
        do {
            return try origin_decodeIfPresent(type, forKey: key)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch(_, _), .dataCorrupted(_):
                do {
                    guard let rawValue = try T.RawValue.decodeIfPresent(by: self, forKey: key, fallback: false) else { return nil }
                    return T(rawValue: rawValue)
                } catch {}
            default:
                break
            }
            return try key.fallbackFrom(error: error)
        }
    }
}

// MARK: - Decode

public extension KeyedDecodingContainer {
    
    func decode<T: SafeDecodable>(_ type: T.Type, forKey key: Self.Key) throws -> T { try type.decode(by: self, forKey: key) }
    func decode(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool { try type.decode(by: self, forKey: key) }
    func decode(_ type: Double.Type, forKey key: Self.Key) throws -> Double { try type.decode(by: self, forKey: key) }
    func decode(_ type: Float.Type, forKey key: Self.Key) throws -> Float { try type.decode(by: self, forKey: key) }
    func decode(_ type: Int.Type, forKey key: Self.Key) throws -> Int { try type.decode(by: self, forKey: key) }
    func decode(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8 { try type.decode(by: self, forKey: key) }
    func decode(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16 { try type.decode(by: self, forKey: key) }
    func decode(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32 { try type.decode(by: self, forKey: key) }
    func decode(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64 { try type.decode(by: self, forKey: key) }
    func decode(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt { try type.decode(by: self, forKey: key) }
    func decode(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8 { try type.decode(by: self, forKey: key) }
    func decode(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16 { try type.decode(by: self, forKey: key) }
    func decode(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32 { try type.decode(by: self, forKey: key) }
    func decode(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64 { try type.decode(by: self, forKey: key) }
}

public extension KeyedDecodingContainer {
    
    func decodeIfPresent<T: SafeDecodable>(_ type: T.Type, forKey key: Self.Key) throws -> T? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Double.Type, forKey key: Self.Key) throws -> Double? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Float.Type, forKey key: Self.Key) throws -> Float? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Int.Type, forKey key: Self.Key) throws -> Int? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32? { try type.decodeIfPresent(by: self, forKey: key) }
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64? { try type.decodeIfPresent(by: self, forKey: key) }
}

// MARK: - Private

private extension SafeDecodable {
    
    static func decode<K: CodingKey>(by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, fallback: Bool = true) throws -> Self {
        do {
            return try container.origin_decode(Self.self, forKey: key)
        } catch let error as DecodingError {
            do {
                if let result = try Self(fallbackFrom: error, by: container, forKey: key) {
                    return result
                }
            } catch {}
            if fallback {
                return try key.fallbackFrom(error: error)
            } else {
                throw error
            }
        }
    }
    
    static func decodeIfPresent<K: CodingKey>(by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, fallback: Bool = true) throws -> Self? {
        do {
            return try container.origin_decodeIfPresent(Self.self, forKey: key)
        } catch let error as DecodingError {
            do {
                return try Self(fallbackFrom: error, by: container, forKey: key)
            } catch {}
            if fallback {
                return try key.fallbackFrom(error: error)
            } else {
                throw error
            }
        }
    }
    
    static func decode(by container: inout UnkeyedDecodingContainer) throws -> Self {
        do {
            return try container.decode(Self.self)
        } catch let error as DecodingError {
            do {
                if let result = try Self(fallbackFrom: error, by: &container) {
                    return result
                }
            } catch {}
            throw error
        }
    }
    
    static func decodeIfPresent(by container: inout UnkeyedDecodingContainer) throws -> Self? {
        do {
            return try container.decodeIfPresent(Self.self)
        } catch let error as DecodingError {
            do {
                return try Self(fallbackFrom: error, by: &container)
            } catch {}
            throw error
        }
    }
}

private extension CodingKey {
    
    func fallbackFrom<T>(error: Error) throws -> T {
        if let customKey = self as? FallbackCodingKey {
            let (fallback, val) = customKey.fallbackValue()
            if fallback, let result = val as? T {
                return result
            }
        }
        throw error
    }
}

private extension KeyedDecodingContainerProtocol {
    
    func origin_decode(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Double.Type, forKey key: Self.Key) throws -> Double { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Float.Type, forKey key: Self.Key) throws -> Float { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Int.Type, forKey key: Self.Key) throws -> Int { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt { try self.decode(type, forKey: key) }
    func origin_decode(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32 { try self.decode(type, forKey: key) }
    func origin_decode(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64 { try self.decode(type, forKey: key) }
    func origin_decode<T>(_ type: T.Type, forKey key: Self.Key) throws -> T where T: Decodable { try self.decode(type, forKey: key) }
}

private extension KeyedDecodingContainerProtocol {
    
    func origin_decodeIfPresent(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Double.Type, forKey key: Self.Key) throws -> Double? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Float.Type, forKey key: Self.Key) throws -> Float? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Int.Type, forKey key: Self.Key) throws -> Int? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64? { try self.decodeIfPresent(type, forKey: key) }
    func origin_decodeIfPresent<T>(_ type: T.Type, forKey key: Self.Key) throws -> T? where T: Decodable { try self.decodeIfPresent(type, forKey: key) }
}
