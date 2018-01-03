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
        
        static func ==(lhs: TestClass.Object, rhs: TestClass.Object) -> Bool {
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
            && a.object.equals(b.object)
    }
}

extension Optional where Wrapped == TestClass.Object {
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
