//
//  TCJSONReflectionCodingKeysTests.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 06/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import TCJSON
import Nimble
import Quick

class TCJSONReflectionCodingKeysSpec: QuickSpec {
    override func spec() {
        
        describe("Coding keys check on ") {
            context("a object without keys"){
                let withoutKeys = TestClass.init()
                
                it("doesn't change") {
                    let keys = try! TCJSONReflection.codingKeysLabels(inObject: withoutKeys)
                    let equalValues = keys.map { $0.key == $0.value }.reduce(true) { $0 && $1 }
                    let equalCount = keys.count == 9
                    expect(equalValues && equalCount).to(beTrue())
                }
            }
            
            context("a simple object") {
                let obj = TestClassWithCodingKeys.init()
                let result = try! TCJSONReflection.codingKeysLabels(inObject: obj)
                
                it("returns the correct number of pairs") {
                    expect(result.count).to(equal(11))
                }
                
                zip(TestClassWithCodingKeys.allCodingKeys,
                    TestClassWithCodingKeys.allCodingKeys.map { $0.rawValue != "nilOptional" })
                    .forEach {
                        createTestCase(
                            with: $0.0,
                            contains: $0.1,
                            withResult: result)
                }
            }
            
            context("a complex object") {
                
                let extremeObj = TestClassWithExtemeCodingKeys.init()
                
                let extremeResult = try! TCJSONReflection.codingKeysLabels(inObject: extremeObj)
                
                TestClassWithExtemeCodingKeys.allCodingKeys.map {
                    return ($0, !(
                        $0.rawValue.contains("disappear")
                            || $0.rawValue == "correct_nilOptional"
                            || $0.rawValue == "correct_nilOptional2"))
                    }.forEach { (info: (TestClassWithExtemeCodingKeys.CodingKeys, Bool)) in
                        createTestCase(
                            with: info.0,
                            contains: info.1,
                            withResult: extremeResult)
                }
            }
            
            func createTestCase(
                with key: CodingKey,
                contains: Bool,
                withResult result: [String: String]) {
                
                it("contains the \(key.stringValue)") {
                    let values = Array(result.values)
                    if contains {
                        expect(values).to(contain(key.stringValue))
                    } else {
                        let shouldNotContainKey: ([String: String]) -> Bool = { !$0.keys.contains(key.stringValue) }
                        let valueShouldBeEmpty: ([String: String]) -> Bool = { $0[key.stringValue]?.isEmpty ?? true }
                        
                        let success = shouldNotContainKey(result) || valueShouldBeEmpty(result)
                        
                        expect(success).to(beTrue())
                    }
                }
            }
        }
    }
}
