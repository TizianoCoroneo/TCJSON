//
//  TestClassWithExtremeCodingKeys.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 03/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import TCJSON

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
    
    let same: String = "a"
    let same2: String = "a"
    let same3: String = "b"
    
    let nilOptional: String? = nil
    let nilOptional2: String? = nil
    let nilOptional3: String? = "aaab"
    
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
    
    let disappear1: Int = 0
    let disappear2: Int = 0
    let disappear3: Int = 1
    
    enum CodingKeys: String, CodingKey {
        case string = "correct_string"
        case string2 = "correct_string2"
        
        case int = "correct_int"
        case int2 = "correct_int2"
        case int3 = "correct_int3"
        
        case double = "correct_double"
        case double2 = "correct_double2"
        case double3 = "correct_double3"
        
        case boolean = "correct_boolean"
        case boolean2 = "correct_boolean2"
        case boolean3 = "correct_boolean3"
        
        case optional = "correct_optional"
        case optional2 = "correct_optional2"
        case optional3 = "correct_optional3"
        
        case same
        case same2
        case same3
        
        case nilOptional = "correct_nilOptional"
        case nilOptional2 = "correct_nilOptional2"
        case nilOptional3 = "correct_nilOptional3"
        
        case array = "correct_array"
        case array2 = "correct_array2"
        case array3 = "correct_array3"
        
        case object = "correct_object"
        case object2 = "correct_object2"
        case object3 = "correct_object3"
        
        case dict = "correct_dict"
        case dict2 = "correct_dict2"
        case dict3 = "correct_dict3"
        case dict4 = "correct_dict4"
        case dict5 = "correct_dict5"
    }
    
    static var allCodingKeys: [CodingKeys] {
        return [
            .string,
            .string2,
            
            .int,
            .int2,
            .int3,
            
            .double,
            .double2,
            .double3,
            
            .boolean,
            .boolean2,
            .boolean3,
            
            .optional,
            .optional2,
            .optional3,
            
            .same,
            .same2,
            .same3,
            
            .nilOptional,
            .nilOptional2,
            .nilOptional3,
            
            .array,
            .array2,
            .array3,
            
            .object,
            .object2,
            .object3,
            
            .dict,
            .dict2,
            .dict3,
            .dict4,
            .dict5,
        ]
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
            
            && a.same == b.same
            && a.same2 == b.same2
            && a.same3 == b.same3
            
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
