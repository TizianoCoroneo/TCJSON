//
//  TestClass.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 03/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import TCJSON

struct TestClass: TCJSONCodable, Equatable {
  var string: String = "aaa"
  let emptyString: String = ""
  var int: Int = 10
  var double: Double = 10.2
  
  var boolean: Bool = true
  var optional: String? = "bbb"
  var nilOptional: String? = nil
  var array: [String] = ["aaa", "bbb"]
  
  var object: Object? = Object(name: "ccc")
  var dict: [String: Int] = ["1": 1]
  
  struct Object: TCJSONCodable {
    let name: String
    
    static func ==(lhs: Object, rhs: Object) -> Bool {
      return lhs.name == rhs.name
    }
  }
  
  static func ==(_ a: TestClass, _ b: TestClass) -> Bool {
    return a.string == b.string
      && a.emptyString == b.emptyString
      && a.int == b.int
      && a.double == b.double
      && a.boolean == b.boolean
      && a.optional == b.optional
      && a.nilOptional == b.nilOptional
      && a.array == b.array
      && a.object == b.object
  }
}

struct TestClassWithCodingKeys: TCJSONCodable, Equatable {
  var string: String = "aaa"
  let emptyString: String = ""
  var int: Int = 10
  var int2: Int = 11
  
  var double: Double = 10.2
  var boolean: Bool = true
  var boolean2: Bool = true
  var optional: String? = "bbb"
  
  var nilOptional: String? = nil
  var array: [String] = ["aaa", "bbb"]
  var object: Object? = Object(name: "ccc")
  var dict: [String: Int] = ["2": 2]
  
  enum CodingKeys: String, CodingKey {
    case string
    //        case emptyString
    case int = "int3"
    case int2 = "int4"
    case double = "changedDouble"
    case boolean = "boolean3"
    case boolean2 // = "boolean4"
    case optional
    case nilOptional
    case array
    case object
    case dict
  }
  
  struct Object: TCJSONCodable {
    let name: String
    
    static func ==(lhs: Object, rhs: Object) -> Bool {
      return lhs.name == rhs.name
    }
  }
  
  static func ==(_ a: TestClassWithCodingKeys, _ b: TestClassWithCodingKeys) -> Bool {
    return a.string == b.string
      && a.emptyString == b.emptyString
      && a.int == b.int
      && a.int2 == b.int2
      && a.double == b.double
      && a.boolean == b.boolean
      && a.boolean2 == b.boolean2
      && a.optional == b.optional
      && a.nilOptional == b.nilOptional
      && a.array == b.array
      && a.object == b.object
  }
}

fileprivate extension Optional where Wrapped == TestClass.Object {
  static func ==(_ a: Wrapped?, _ b: Wrapped?) -> Bool {
    return a.equals(b)
  }
  
  func equals(_ other: TestClass.Object?) -> Bool {
    switch self {
    case nil:
      return other == nil
    case let value:
      guard let other = other else { return false }
      return other == value!
    }
  }
}

fileprivate extension Optional where Wrapped == TestClassWithCodingKeys.Object {
  static func ==(_ a: Wrapped?, _ b: Wrapped?) -> Bool {
    switch a {
    case nil:
      return b == nil
    default:
      guard let other = b else { return false }
      return other == a!
    }
  }
}
