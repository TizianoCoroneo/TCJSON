//
//  CorePerformance.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 04/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest

class CorePerformance: XCTestCase {
  
  let object = TestClass()
  let optionalObject = Optional.some(TestClass())
  let doubleOptionalObject = Optional.some(TestClass())
  let objectWithCoding = TestClassWithCodingKeys()
  let nilObject: TestClass? = nil

  override func setUp() { super.setUp() }
  override func tearDown() { super.tearDown() }
  
  func testPerformance_toData() { measure {
    try! make(object, .mediumSmall)
      .forEach { _ = try $0.json.data() }
    }}
  
  func testPerformance_toDictionary() { measure {
    try! make(object, .mediumSmall)
      .forEach { _ = try $0.json.dictionary() }
    }}
  
  func testPerformance_fromJSONString() { measure {
    try! make(0, .mediumSmall).forEach { _ in
      _ = try TestClass(fromJSONString: TCJSONSpec.exampleJSONString)
    }}}
  
  func testPerformance_fromDictionary() { measure {
    try! make(0, .mediumSmall).forEach { _ in
      _ = try TestClass(fromDictionary: TCJSONSpec.exampleDictionary)
    }}}
  
}
