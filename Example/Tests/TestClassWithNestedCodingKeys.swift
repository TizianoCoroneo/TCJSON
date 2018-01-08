//
//  TestClassWithNestedCodingKeys.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 08/01/2018.
//  Copyright © 2018 Tiziano Coroneo. All rights reserved.
//

import TCJSON

struct TestClassWithNestedCodingKeys: TCJSONCodable, Equatable {
    let string: String = "aaa"
    
    let int: Int = 10
    let double: Double = 10.2
    let boolean: Bool = true
    
    let object: Object? = Object(name: "ccc", int: 1)
    
    enum CodingKeys: String, CodingKey {
        case string
        case int = "int2"
        case double = "double2"
        case boolean = "boolean2"
        
        case object
    }
    
    static var allCodingKeys: [CodingKeys] {
        return [
            .string,
            .int,
            .double,
            .boolean,
            .object
        ]
    }
    
    struct Object: TCJSONCodable {
        let name: String
        let int: Int
        
        enum CodingKeys: String, CodingKey {
            case name
            case int = "int2"
        }
        
        static func ==(lhs: Object, rhs: Object) -> Bool {
            return lhs.name == rhs.name
            && lhs.int == rhs.int
        }
    }
    
    static func ==(
        _ a: TestClassWithNestedCodingKeys,
        _ b: TestClassWithNestedCodingKeys) -> Bool {
        return a.string == b.string
            && a.int == b.int
            && a.double == b.double
            && a.boolean == b.boolean
            && a.object == b.object
    }
}

fileprivate extension Optional where Wrapped == TestClassWithNestedCodingKeys.Object {
    static func ==(_ a: Wrapped?, _ b: Wrapped?) -> Bool {
        return a.equals(b)
    }
    
    func equals(_ other: TestClassWithNestedCodingKeys.Object?) -> Bool {
        switch self {
        case nil:
            return other == nil
        case let value:
            guard let other = other else { return false }
            return other == value!
        }
    }
}
