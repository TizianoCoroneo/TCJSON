//
//  TCJSONReflectionEqualityTests.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 03/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import TCJSON
import Nimble
import Quick

class TCJSONReflectionEqualitySpec: QuickSpec {
    override func spec() {
        describe("Equality") {
            let value = "test"
            enum ThrowingType: String {
                case string
                case int
                case double
                case bool
                case array
                case optional
                case optionalObject
                case nilOptionalObject
                case nilOptional
                case numberOne
                case numberZero
                case someNil
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
                        .optionalObject,
                        .nilOptionalObject,
                        .nilOptional,
                        .numberOne,
                        .numberZero,
                        .someNil,
                        .dict,
                        .object
                    ]
                }
            }
            
            let compatibilityTable: [(ThrowingType, ThrowingType)] = [
                (.nilOptional, .nilOptionalObject),
            ]
            
            let expectedValues: [ThrowingType: Any] = [
                .string: "aaa",
                .int: 2,
                .double: 3.0,
                .bool: true,
                .array: ["a", "b"],
                .optional:  Optional<String>.some("lol") as Any,
                .optionalObject:  Optional.some(TestClass.Object.init(name: "aac")) as Any,
                .nilOptionalObject: Optional<TestClass.Object>.none as Any,
                .nilOptional: Optional<String>.none as Any,
                .numberZero: 0,
                .numberOne: 1,
                .someNil: Optional<Any?>.some(Optional<Any>.none) as Any,
                .dict: ["lol": 3],
                .object: TestClass.Object(name: "q")]
            
            func createTestContext(_ ownType: ThrowingType) {
                func isCompatible(
                    _ a: ThrowingType,
                    _ b: ThrowingType,
                    table: [(ThrowingType, ThrowingType)]) -> Bool {
                    let forwardResult = table.filter({ $0.0 == a }).map { $0.1 }
                    let reverseResult = table.filter({ $0.1 == a }).map { $0.0 }
                    let forwardResultSet = Set.init(forwardResult)
                    let reverseResultSet = Set.init(reverseResult)
                    let resultSet = forwardResultSet.union(reverseResultSet)
                    return resultSet.contains(b) || a == b
                }
                context("when given a \(ownType.rawValue)") {
                    ThrowingType.all.forEach { otherType in
                        let success = ownType == otherType
                            || isCompatible(
                                ownType,
                                otherType,
                                table: compatibilityTable)
                        createTestCase(ownType, otherType, shouldBe: success)
                    }
                }
            }
            
            func createTestCase(_ ownType: ThrowingType, _ otherType: ThrowingType, shouldBe success: Bool) {
                it("should be \(success) with a \(otherType.rawValue)") {
                    let result = Mirror.equals(
                      expectedValues[ownType]!,
                      expectedValues[otherType]!)
                    expect(result).to(equal(success))
                }
            }
            
            ThrowingType.all.forEach { ownType in
                createTestContext(ownType)
            }
            
            context("when comparing a value and a Optional") {
                it("should be true with same value") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some("SSS" as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beTrue())
                }
                
                it("should be true with same value reversed") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some("SSS" as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beTrue())
                }
                
                it("should be false with different value") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some("aaa" as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beFalse())
                }
                
                it("should be false with a object") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some("aaa" as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beFalse())
                }
                
                it("should be false with different value reversed") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some("aaa" as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beFalse())
                }
                
                it("should be true with same value in double optional") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some(Optional.some("SSS" as Any) as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beTrue())
                }
                
                it("should be false with same value in double optional") {
                    let string: Any = "SSS"
                    let optString: Any = Optional.some(Optional.some("aaa" as Any) as Any) as Any
                    let result = Mirror.equals(string, optString)
                    expect(result).to(beFalse())
                }
            }
        }
    }
}
