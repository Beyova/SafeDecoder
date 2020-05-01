//
//  SafeDecoder.swift
//  SafeDecoder
//
//  Created by canius.chu on 2020/1/5.
//  Copyright © 2020 Beyova. All rights reserved.
//

import Foundation

public class SafeDecoder: JSONDecoder {
    
    public struct Config {
        public var onError: ((Error, String) -> Void)?
    }
    
    public var config = Config()
    
    private static let threadSafeSharedConfigKey = "com.beyova.SafeDecoder.Config"
    
    static var config: Config? {
        return Thread.current.threadDictionary[Self.threadSafeSharedConfigKey] as? Config
    }
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        defer {
            Thread.current.threadDictionary.removeObject(forKey: Self.threadSafeSharedConfigKey)
        }
        Thread.current.threadDictionary[Self.threadSafeSharedConfigKey] = config
        return try super.decode(type, from: data)
    }
}
