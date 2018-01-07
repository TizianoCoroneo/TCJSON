//
//  ReflectionPerformance.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 04/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import TCJSON

class ReflectionPerformance: XCTestCase {
    
    let object = TestClass()
    let optionalObject = Optional.some(TestClass())
    let doubleOptionalObject = Optional.some(TestClass())
    let objectWithCoding = TestClassWithCodingKeys()
    let extremeObjectWithCoding = TestClassWithExtemeCodingKeys()
    let nilObject: TestClass? = nil
    
    override func setUp() { super.setUp() }
    override func tearDown() { super.tearDown() }
    
    func testMeasure_isNil() { measure {
        makeAny(nilObject as Any, .mediumLarge)
            .forEach { _ = TCJSONReflection.isNil($0) }
        }}
    
    func testMeasure_isOptional() { measure {
        makeAny(optionalObject as Any, .mediumLarge)
            .forEach { _ = TCJSONReflection.isOptional($0) }
        }}
    
    func testMeasure_flattenDoubleOptional() { measure {
        makeAny(doubleOptionalObject as Any, .mediumLarge)
            .forEach { _ = TCJSONReflection.unwrapOptional($0) }
        }}
    
    func testMeasure_equality() { measure {
        make(ThrowingType.all, .small)
            .forEach { _ = $0.forEach(createTestContext) }}}
    
    func testMeasure_interpret() { measure {
        make(object, .mediumSmall)
            .forEach { _ = try? TCJSONReflection.interpret($0) }
        }}
    
    func testMeasure_codingKeys() { measure {
        make(objectWithCoding, .small)
            .forEach { _ = try? TCJSONReflection.codingKeysLabels(inObject: $0) }
        }}
    
    func testMeasure_extremeCodingKeys() { measure {
        make(extremeObjectWithCoding, .small)
            .forEach { _ = try? TCJSONReflection.codingKeysLabels(inObject: $0) }
        }}
}

enum Runs: Int {
    case small = 100
    case mediumSmall = 1_000
    case medium = 10_000
    case mediumLarge = 40_000
    case large = 100_000
}

func make<T>(_ any: T, _ n: Runs) -> [T] {
    return Array.init(repeating: any, count: n.rawValue)
}

func makeAny(_ any: Any, _ n: Runs) -> [Any] {
    return Array.init(repeating: any, count: n.rawValue)
}

enum ThrowingType: String {
    case string
    case int
    case double
    case bool
    case array
    case optional
    case nilOptional
    case dict
    case object
    
    static var all: [ThrowingType] {
        return [
            .string,
            .int,
            .double,
            .bool,
            .array,
            .optional,
            .nilOptional,
            .dict,
            .object
        ]
    }
}

let expectedValues: [ThrowingType: Any] = [
    .string: "aaa",
    .int: 2,
    .double: 2.0,
    .bool: true,
    .array: ["a", "b"],
    .optional:  Optional<String>.some("lol") as Any,
    .nilOptional: Optional<String>.none as Any,
    .dict: ["lol": "test"],
    .object: TestClass.Object(name: "q")]

func createTestContext(_ ownType: ThrowingType) {
    ThrowingType.all.forEach { otherType in
        createTestCase(ownType, otherType, shouldBe: ownType == otherType)
    }
}

func createTestCase(_ ownType: ThrowingType, _ otherType: ThrowingType, shouldBe success: Bool) {
    let result = TCJSONReflection.equals(
        expectedValues[ownType]!,
        expectedValues[otherType]!)
    XCTAssert(result == success)
}
