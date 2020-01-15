//
//  SafeDecoderTests.swift
//  SafeDecoderTests
//
//  Created by canius.chu on 2020/1/5.
//  Copyright © 2020 Beyova. All rights reserved.
//

import XCTest
import SafeDecoder

final class SafeDecoderTests: XCTestCase {

    let decoder = JSONDecoder()
    
    override func setUp() {
        decoder.dateDecodingStrategy = .iso8601
    }

    override func tearDown() {
    }
    
    func testInt() {
        struct TestClass: Codable {
            let value: Int
            let optional: Int?
            let array: [Int]
            let optionalArray: [Int]?
        }
        runDecode(json: ["value": 1, "optional": 1, "array": [1,2,3], "optionalArray": [1,2,3]], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, 1)
            XCTAssertEqual(obj.optional, 1)
            XCTAssertEqual(obj.array, [1,2,3])
            XCTAssertEqual(obj.optionalArray, [1,2,3])
        }
        runDecode(json: ["value": "1", "array": ["1", 2, "3"]], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, 1)
            XCTAssertNil(obj.optional)
            XCTAssertEqual(obj.array, [1,2,3])
            XCTAssertNil(obj.optionalArray)
        }
    }
    
    func testString() {
        struct TestClass: Codable {
            let value: String
            let optional: String?
        }
        runDecode(json: ["value": "a"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, "a")
            XCTAssertNil(obj.optional)
        }
    }
    
    func testBool() {
        struct TestClass: Codable {
            let value: Bool
            let optional: Bool?
        }
        runDecode(json: ["value": true, "optional": true], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, true)
            XCTAssertEqual(obj.optional, true)
        }
        runDecode(json: ["value": false], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, false)
            XCTAssertNil(obj.optional)
        }
        runDecode(json: ["value": "true"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, true)
        }
        runDecode(json: ["value": "True"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, true)
        }
        runDecode(json: ["value": "false"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, false)
        }
        runDecode(json: ["value": "False"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, false)
        }
    }
    
    func testEnum() {
        
        enum TestEnum: String, Codable {
            case one
            case two
        }
        
        struct TestClass: Codable {
            let value: TestEnum
            let optional: TestEnum?
        }
        runDecode(json: ["value": "two", "optional": "two"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertEqual(obj.optional, TestEnum.two)
        }
        runDecode(json: ["value": "two"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertNil(obj.optional)
        }
        runDecode(json: ["value": "two", "optional": "x"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertNil(obj.optional)
        }
        runDecode(json: ["value": "two", "optional": ""], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertNil(obj.optional)
        }
    }
    
    func testIntEnum() {
        enum TestEnum: Int, Codable {
            case one = 1
            case two
        }
        
        struct TestClass: Codable {
            let value: TestEnum
            let optional: TestEnum?
        }
        
        runDecode(json: ["value": 2], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertNil(obj.optional)
        }
        
        runDecode(json: ["value": 2, "optional": 2], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertEqual(obj.optional, TestEnum.two)
        }
        
        runDecode(json: ["value": "2", "optional": "2"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertEqual(obj.optional, TestEnum.two)
        }
        
        runDecode(json: ["value": 2, "optional": "3"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertNil(obj.optional)
        }
    }
    
    func testDate() {
        struct TestClass: Codable {
            let value: Date
            let optional: Date?
        }
        runDecode(json: ["value": "2019-01-01T01:01:01Z", "optional": "2019-01-01T01:01:01Z"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertNotNil(obj.optional)
        }
        runDecode(json: ["value": "2019-01-01T01:01:01Z", "optional": ""], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertNil(obj.optional)
        }
    }
    
    func testArrayOfArray() {
        struct TestClass: Codable {
            let array: [[Int]]
        }
        runDecode(json: ["array": [[1,"2",3],["1",2,"3"]]], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.array, [[1,2,3],[1,2,3]])
        }
    }
    
    func testFallbackCodingKey() {
        
        enum TestEnum: String, Codable {
            case one
            case two
        }
        
        struct TestClass: Codable {
            let value: Int
            let optional: Int?
            let array: [Int]
            let enumValue: TestEnum
            
            enum CodingKeys: String, FallbackCodingKey {

                case value, optional, array, enumValue

                func fallbackValue() -> Any? {
                    switch self {
                    case .value: return 42
                    case .optional: return 999
                    case .array: return []
                    case .enumValue: return TestEnum.one
                    }
                }
            }
        }

        runDecode(json: [:], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, 42)
            XCTAssertNil(obj.optional)
            XCTAssertEqual(obj.array, [])
            XCTAssertEqual(obj.enumValue, .one)
        }
        runDecode(json: ["value":123, "optional": "1"], type: TestClass.self, fail: { error in XCTFail("\(error)") }) { obj in
            XCTAssertEqual(obj.value, 123)
            XCTAssertEqual(obj.optional, 1)
            XCTAssertEqual(obj.array, [])
        }
    }

    // MARK: Private
    
    private struct RootClass<T: Codable>: Codable {
        let object: T
        let array: [T]
    }
    
    private func runDecode<T: Codable>(json: Any, type: T.Type, fail: (_ error: Error) -> Void, validation: (_ result: T) -> Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let result = try decoder.decode(T.self, from: data)
            validation(result)
        } catch {
            fail(error)
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: [json, json], options: [])
            let result = try decoder.decode([T].self, from: data)
            result.forEach({ validation($0) })
        } catch {
            fail(error)
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: ["object": json, "array": [json, json]], options: [])
            let result = try decoder.decode(RootClass<T>.self, from: data)
            validation(result.object)
            result.array.forEach({ validation($0) })
        } catch {
            fail(error)
            return
        }
    }
}
