//
//  SafeDecodable.swift
//  SafeDecoder
//
//  Created by canius.chu on 2020/1/5.
//  Copyright © 2020 Beyova. All rights reserved.
//

import Foundation

public protocol SafeDecodable: Decodable {
    
    init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, config: SafeDecoder.Config) throws
    
    init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer, config: SafeDecoder.Config) throws
    
    init?(fallbackFrom string: String)
}

// MARK: - Fallback

public typealias FallbackValue = (fallback: Bool, value: Any?)

public protocol FallbackCodingKey: CodingKey {
    
    func fallbackValue() -> FallbackValue
}

extension CodingKey {
    
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

// MARK: - SafeDecodable Default Impl

public extension SafeDecodable {

    init?<K: CodingKey>(fallbackFrom error: DecodingError, by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, config: SafeDecoder.Config) throws {
        if case DecodingError.typeMismatch(_, _) = error {
            let string = try container.decode(String.self, forKey: key)
            if let val =  Self(fallbackFrom: string) {
                self = val
                return
            }
        }
        throw error
    }
    
    init?(fallbackFrom error: DecodingError, by container: inout UnkeyedDecodingContainer, config: SafeDecoder.Config) throws {
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

// MARK: - Decode

extension SafeDecodable {
    
    static func decode<K: CodingKey>(by container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, fallback: Bool = true) throws -> Self {
        guard let config = SafeDecoder.config else {
            return try container.origin_decode(Self.self, forKey: key)
        }
        do {
            return try container.origin_decode(Self.self, forKey: key)
        } catch let error as DecodingError {
            do {
                if let result = try Self(fallbackFrom: error, by: container, forKey: key, config: config) {
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
        guard let config = SafeDecoder.config else {
            return try container.origin_decodeIfPresent(Self.self, forKey: key)
        }
        do {
            return try container.origin_decodeIfPresent(Self.self, forKey: key)
        } catch let error as DecodingError {
            do {
                return try Self(fallbackFrom: error, by: container, forKey: key, config: config)
            } catch {}
            if fallback {
                return try key.fallbackFrom(error: error)
            } else {
                throw error
            }
        }
    }
    
    static func decode(by container: inout UnkeyedDecodingContainer) throws -> Self {
        guard let config = SafeDecoder.config else {
            return try container.decode(Self.self)
        }
        do {
            return try container.decode(Self.self)
        } catch let error as DecodingError {
            do {
                if let result = try Self(fallbackFrom: error, by: &container, config: config) {
                    return result
                }
            } catch {}
            throw error
        }
    }
    
    static func decodeIfPresent(by container: inout UnkeyedDecodingContainer) throws -> Self? {
        guard let config = SafeDecoder.config else {
            return try container.decode(Self.self)
        }
        do {
            return try container.decodeIfPresent(Self.self)
        } catch let error as DecodingError {
            do {
                return try Self(fallbackFrom: error, by: &container, config: config)
            } catch {}
            throw error
        }
    }
}

// MARK: - Override

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

extension KeyedDecodingContainerProtocol {
    
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

extension KeyedDecodingContainerProtocol {
    
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
