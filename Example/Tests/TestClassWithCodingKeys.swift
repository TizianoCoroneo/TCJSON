//
//  TestClassWithCodingKeys.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 03/01/2018.
//  Copyright © 2018 Tiziano Coroneo. All rights reserved.
//

import TCJSON

struct TestClassWithCodingKeys: TCJSONCodable, Equatable {
    let string: String = "aaa"
    let emptyString: String = ""
    let int: Int = 10
    let int2: Int = 11
    
    let double: Double = 10.2
    let boolean: Bool = true
    let boolean2: Bool = false
    let optional: String? = "bbb"
    
    let nilOptional: String? = nil
    let array: [String] = ["aaa", "bbb"]
    let object: Object? = Object(name: "ccc")
    let dict: [String: Int] = ["2": 2]
    
    enum CodingKeys: String, CodingKey {
        case string
        case emptyString
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
    
    static var allCodingKeys: [CodingKeys] {
        return [
            .string,
            .emptyString,
            .int,
            .int2,
            .double,
            .boolean,
            .boolean2,
            .optional,
            .nilOptional,
            .array,
            .object,
            .dict,
        ]
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
