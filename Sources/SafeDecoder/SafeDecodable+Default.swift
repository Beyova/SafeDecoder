//
//  SafeDecodable+Default.swift
//  SafeDecoder
//
//  Created by canius.chu on 2020/1/5.
//  Copyright © 2020 Beyova. All rights reserved.
//

import Foundation

// MARK: - Special

extension Date: SafeDecodable {

    public init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: K, config: SafeDecoder.Config) throws {
        if case DecodingError.dataCorrupted(_) = error {
            let string = try container.origin_decode(String.self, forKey: key)
            if string.isEmpty { return nil }
        }
        throw error
    }
    
    public init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer, config: SafeDecoder.Config) throws {
        if case DecodingError.dataCorrupted(_) = error {
            let string = try container.decode(String.self)
            if string.isEmpty { return nil }
        }
        throw error
    }
    
    public init?(fallbackFrom string: String) { return nil }
}

extension URL: SafeDecodable {

    public init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: K, config: SafeDecoder.Config) throws {
        if case DecodingError.dataCorrupted(_) = error {
            let string = try container.origin_decode(String.self, forKey: key)
            config.onError?(error, string)
            return nil
        }
        throw error
    }

    public init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer, config: SafeDecoder.Config) throws {
        if case DecodingError.dataCorrupted(_) = error {
            let string = try container.decode(String.self)
            config.onError?(error, string)
            return nil
        }
        throw error
    }

    public init?(fallbackFrom string: String) { return nil }
}

extension Array: SafeDecodable where Element: SafeDecodable {

    public init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: K, config: SafeDecoder.Config) throws {
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
    
    public init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer, config: SafeDecoder.Config) throws {
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
        guard SafeDecoder.config != nil else { return try origin_decode(type, forKey: key) }
        do {
            return try origin_decode(type, forKey: key)
        } catch let error as DecodingError {
            return try key.fallbackFrom(error: error)
        }
    }
    
    func decodeIfPresent<T: RawRepresentable & Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T? where T.RawValue == String {
        guard let config = SafeDecoder.config else { return try origin_decodeIfPresent(type, forKey: key) }
        do {
            return try origin_decodeIfPresent(type, forKey: key)
        } catch let error as DecodingError {
            if case DecodingError.dataCorrupted(_) = error {
                do {
                    if let string = try decodeIfPresent(String.self, forKey: key), !string.isEmpty {
                        config.onError?(error, string)
                    }
                    return nil
                } catch {}
                return try key.fallbackFrom(error: error)
            }
            throw error
        }
    }
    
    func decode<T: RawRepresentable & Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T where T.RawValue: SafeDecodable {
        guard SafeDecoder.config != nil else { return try origin_decode(type, forKey: key) }
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
        guard SafeDecoder.config != nil else { return try origin_decodeIfPresent(type, forKey: key) }
        do {
            return try origin_decodeIfPresent(type, forKey: key)
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch, .dataCorrupted:
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

// MARK: - Simple

extension String: SafeDecodable {

    public init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: K, config: SafeDecoder.Config) throws {
        if case DecodingError.typeMismatch = error {
            if let val = try? container.origin_decode(Int64.self, forKey: key) {
                self = String(val)
                return
            }
            if let val = try? container.origin_decode(Double.self, forKey: key) {
                self = String(val)
                return
            }
            if let val = try? container.origin_decode(Bool.self, forKey: key) {
                self = String(val)
                return
            }
        }
        throw error
    }
    
    public init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer, config: SafeDecoder.Config) throws {
        if case DecodingError.typeMismatch = error {
            if let val = try? container.decode(Int64.self) {
                self = String(val)
                return
            }
            if let val = try? container.decode(Double.self) {
                self = String(val)
                return
            }
            if let val = try? container.decode(Bool.self) {
                self = String(val)
                return
            }
        }
        throw error
    }
    
    public init?(fallbackFrom string: String) { nil }
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
