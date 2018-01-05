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
  let string: String = "aaa"
  let emptyString: String = ""
  let int: Int = 10
  let int2: Int = 11
  
  let double: Double = 10.2
  let boolean: Bool = true
  let boolean2: Bool = true
  let optional: String? = "bbb"
  
  let nilOptional: String? = nil
  let array: [String] = ["aaa", "bbb"]
  let object: Object? = Object(name: "ccc")
  let dict: [String: Int] = ["2": 2]
  
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

struct TestClassWithExtemeCodingKeys: TCJSONCodable, Equatable {
  let string: String = "aaa"
  let string2: String = "bbb"
  
  let int: Int = 11
  let int2: Int = 11
  let int3: Int = 10
  
  let double: Double = 10.2
  let double2: Double = 10.2
  let double3: Double = 11.2
  
  let boolean: Bool = true
  let boolean2: Bool = true
  let boolean3: Bool = false
  
  let optional: String? = "bbb"
  let optional2: String? = "bbb"
  let optional3: String? = "aaa"
  
  let nilOptional: String? = nil
  let nilOptional2: String? = nil
  let nilOptional3: String? = "aaa"
  
  let array: [String] = ["aaa", "bbb"]
  let array2: [String] = ["aaa", "bbb"]
  let array3: [String] = ["aaa"]
  
  let object: Object? = Object(name: "ccc")
  let object2: Object? = Object(name: "ccc")
  let object3: Object = Object(name: "ddd")
  
  let dict: [String: Int] = ["2": 2]
  let dict2: [String: Int] = ["2": 2]
  let dict3: [String: Int] = ["3": 2]
  let dict4: [String: Int] = ["2": 4]
  let dict5: [String: Int] = ["3": 4]
  
  let disappear1 = 0
  let disappear2 = 0
  let disappear3 = 1
  
  enum CodingKeys: String, CodingKey {
    case string = "string3"
    case string2 = "string4"
    
    case int = "int4"
    case int2 = "int5"
    case int3 = "int6"
    
    case double = "double3"
    case double2 = "double4"
    case double3 = "double5"
    
    case boolean = "boolean2"
    case boolean2 = "boolean3"
    case boolean3 = "boolean4"
    
    case optional = "optional4"
    case optional2 = "optional5"
    case optional3 = "optional6"
    
    case nilOptional = "nilOptional4"
    case nilOptional2 = "nilOptional5"
    case nilOptional3 = "nilOptional6"
    
    case array = "array4"
    case array2 = "array5"
    case array3 = "array6"
    
    case object = "object4"
    case object2 = "object5"
    case object3 = "object6"
    
    case dict = "dict6"
    case dict2 = "dict7"
    case dict3 = "dict8"
    case dict4 = "dict9"
    case dict5 = "dict10"
  }
  
  struct Object: TCJSONCodable {
    let name: String
    
    static func ==(lhs: Object, rhs: Object) -> Bool {
      return lhs.name == rhs.name
    }
  }
  
  static func ==(
    _ a: TestClassWithExtemeCodingKeys,
    _ b: TestClassWithExtemeCodingKeys) -> Bool {
    return a.string == b.string
    && a.string2 == b.string2
    
    && a.int == b.int
    && a.int2 == b.int2
    && a.int3 == b.int3
    
    && a.double == b.double
    && a.double2 == b.double2
    && a.double3 == b.double3
    
    && a.boolean == b.boolean
    && a.boolean2 == b.boolean2
    && a.boolean3 == b.boolean3
    
    && a.optional == b.optional
    && a.optional2 == b.optional2
    && a.optional3 == b.optional3
    
    && a.nilOptional == b.nilOptional
    && a.nilOptional2 == b.nilOptional2
    && a.nilOptional3 == b.nilOptional3
    
    && a.array == b.array
    && a.array2 == b.array2
    && a.array3 == b.array3
    
    && a.object == b.object
    && a.object2 == b.object2
    && a.object3 == b.object3
    
    && a.dict == b.dict
    && a.dict2 == b.dict2
    && a.dict3 == b.dict3
    && a.dict4 == b.dict4
    && a.dict5 == b.dict5
    
    && a.disappear1 == b.disappear1
    && a.disappear2 == b.disappear2
    && a.disappear3 == b.disappear3
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

fileprivate extension Optional where Wrapped == TestClassWithExtemeCodingKeys.Object {
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
