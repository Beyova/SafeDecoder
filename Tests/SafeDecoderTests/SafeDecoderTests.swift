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

    let decoder = SafeDecoder()
    
    override func setUp() {
        decoder.dateDecodingStrategy = .iso8601
        decoder.config.onError = { error, value in
            print("SafeDecoder error: \(error) for value: \(value)")
        }
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
        XCTAssertSuccessReturn(try decode(json: ["value": 1, "optional": 1, "array": [1,2,3], "optionalArray": [1,2,3]], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, 1)
            XCTAssertEqual(obj.optional, 1)
            XCTAssertEqual(obj.array, [1,2,3])
            XCTAssertEqual(obj.optionalArray, [1,2,3])
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "1", "array": ["1", 2, "3"]], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, 1)
            XCTAssertNil(obj.optional)
            XCTAssertEqual(obj.array, [1,2,3])
            XCTAssertNil(obj.optionalArray)
        })
    }
    
    func testString() {
        struct TestClass: Codable {
            let value: String
            let optional: String?
        }
        XCTAssertSuccessReturn(try decode(json: ["value": "a"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, "a")
            XCTAssertNil(obj.optional)
        })
    }
    
    func testBool() {
        struct TestClass: Codable {
            let value: Bool
            let optional: Bool?
        }
        XCTAssertSuccessReturn(try decode(json: ["value": true, "optional": true], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, true)
            XCTAssertEqual(obj.optional, true)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": false], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, false)
            XCTAssertNil(obj.optional)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "true"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, true)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "True"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, true)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "false"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, false)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "False"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, false)
        })
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
        XCTAssertSuccessReturn(try decode(json: ["value": "two", "optional": "two"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertEqual(obj.optional, TestEnum.two)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "two"], type: TestClass.self) { obj in
            XCTAssertNil(obj.optional)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "two", "optional": "x"], type: TestClass.self) { obj in
            XCTAssertNil(obj.optional)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "two", "optional": ""], type: TestClass.self) { obj in
            XCTAssertNil(obj.optional)
        })
    }
    
    func testIntEnum() {
        enum TestEnum: Int, Codable {
            case one = 1
            case two
        }
        struct TestClass: Codable {
            let value: TestEnum
            let optional: TestEnum?
            
            enum CodingKeys: String, FallbackCodingKey {
                case value, optional
                
                func fallbackValue() -> FallbackValue {
                    switch self {
                    case .value:
                        return (true, TestEnum.one)
                    default:
                        return (false, nil)
                    }
                }
            }
        }
        XCTAssertSuccessReturn(try decode(json: ["value": 2], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertNil(obj.optional)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": 2, "optional": 2], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertEqual(obj.optional, TestEnum.two)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "2", "optional": "2"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertEqual(obj.optional, TestEnum.two)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": 2, "optional": "3"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, TestEnum.two)
            XCTAssertNil(obj.optional)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "x"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, TestEnum.one)
        })
    }
    
    func testDate() {
        struct TestClass: Codable {
            let value: Date
            let optional: Date?
        }
        XCTAssertSuccessReturn(try decode(json: ["value": "2019-01-01T01:01:01Z", "optional": "2019-01-01T01:01:01Z"], type: TestClass.self) { obj in
            XCTAssertNotNil(obj.optional)
        })
        XCTAssertSuccessReturn(try decode(json: ["value": "2019-01-01T01:01:01Z", "optional": ""], type: TestClass.self) { obj in
            XCTAssertNil(obj.optional)
        })
    }
    
    func testURL() {
        struct TestClass: Codable {
            let url: URL?
            let string: String?
        }
        XCTAssertSuccessReturn(try decode(json: ["url": "I'm not a URL"], type: TestClass.self) { obj in
            XCTAssertNil(obj.url)
            XCTAssertNil(obj.string)
        })

        XCTAssertSuccessReturn(try decode(json: ["url": "beyova://test/abc", "string": "some String"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.url?.absoluteString, "beyova://test/abc")
            XCTAssertNotNil(obj.string)
        })
    }
    
    func testArrayOfArray() {
        struct TestClass: Codable {
            let array: [[Int]]
        }
        XCTAssertSuccessReturn(try decode(json: ["array": [[1,"2",3],["1",2,"3"]]], type: TestClass.self) { obj in
            XCTAssertEqual(obj.array, [[1,2,3],[1,2,3]])
        })
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

                func fallbackValue() -> FallbackValue {
                    switch self {
                    case .value: return (true, 42)
                    case .optional: return (true, nil)
                    case .array: return (true, [])
                    case .enumValue: return (true, TestEnum.one)
                    }
                }
            }
        }
        XCTAssertSuccessReturn(try decode(json: [:], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, 42)
            XCTAssertNil(obj.optional)
            XCTAssertEqual(obj.array, [])
            XCTAssertEqual(obj.enumValue, .one)
        })
        XCTAssertSuccessReturn(try decode(json: ["value":123, "optional": "1"], type: TestClass.self) { obj in
            XCTAssertEqual(obj.value, 123)
            XCTAssertEqual(obj.optional, 1)
            XCTAssertEqual(obj.array, [])
        })
        XCTAssertSuccessReturn(try decode(json: ["optional": "x", "enumValue": "x"], type: TestClass.self) { obj in
            XCTAssertNil(obj.optional)
            XCTAssertEqual(obj.enumValue, .one)
        })
    }
    
    func testComplexStructure() {
        struct RootClass: Codable {
            let object: TestClass
            let array: [TestClass]
        }
        struct TestClass: Codable {
            let value: Int
        }
        let json = ["value": "1"]
        let validation = { (obj: TestClass) in
            XCTAssertEqual(obj.value, 1)
        }
        XCTAssertSuccessReturn(try decode(json: json, type: TestClass.self) { obj in
            validation(obj)
        })
        XCTAssertSuccessReturn(try decode(json: [json, json], type: [TestClass].self) { obj in
            obj.forEach({ validation($0) })
        })
        XCTAssertSuccessReturn(try decode(json: ["object": json, "array": [json, json]], type: RootClass.self) { obj in
            validation(obj.object)
            obj.array.forEach({ validation($0) })
        })
    }
    
    func testMultiThread() {
        struct TestClass: Codable {
            let value: Int
        }
        let exp = expectation(description: "decode multi-thread JSONDecoder vs SafeDecoder")
        exp.expectedFulfillmentCount = 100
        
        let decoder = JSONDecoder()
        let safeDecoder = SafeDecoder()
        let json = ["value": "1"]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        for _ in 0..<50 {
            DispatchQueue.global().async {
                do {
                    _ = try decoder.decode(TestClass.self, from: data)
                } catch {
                    exp.fulfill()
                }
            }
        }
        
        for _ in 0..<50 {
            DispatchQueue.global().async {
                do {
                    let obj = try safeDecoder.decode(TestClass.self, from: data)
                    XCTAssertEqual(obj.value, 1)
                    exp.fulfill()
                } catch {
                    XCTFail("\(error)")
                }
            }
        }
        
        wait(for: [exp], timeout: 3)
    }
    
    private func decode<T: Codable>(json: Any, type: T.Type, validation: (_ obj: T) -> Void) throws {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let obj = try decoder.decode(T.self, from: data)
        validation(obj)
    }
}

func XCTAssertSuccessReturn<T>(_ expression: @autoclosure () throws -> T, in file: StaticString = #file, line: UInt = #line) {
    do {
        _ = try expression()
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}
