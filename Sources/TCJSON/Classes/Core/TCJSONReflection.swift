//
//  TCJSONReflection.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 02/01/2018.
//

import Foundation

class TCJSONReflection {
    
    /// Interprets a value into a valid JSON object representation of it.
    ///
    /// - Parameter value: The value to interpret.
    /// - Returns: A valid JSON object.
    /// - Throws: From interpreting the inner values with the wrong func.
    public static func interpret(_ value: Any) throws -> Any {
        let mirror = Mirror(reflecting: value)
        
        guard let type = mirror.displayStyle else { return value }
        
        switch type {
        case .class,
             .struct:
            return try interpretObject(value)
        case .collection:
            return try interpretArray(value)
        case .optional:
            return try interpretOptional(value)
        case .dictionary:
            return try interpretDictionary(value)
        default:
            return value
        }
    }
    
    /// Interprets an object into a valid JSON object representation of it.
    ///
    /// - Parameter value: The object to interpret.
    /// - Returns: A valid JSON object.
    /// - Throws: From passing as argument something that is not an object.
    public static func interpretObject(_ object: Any) throws -> [String: Any] {
        let mirror = Mirror(reflecting: object)
        
        guard mirror.displayStyle == .class
            || mirror.displayStyle == .struct
            else { throw TCJSONReflectionError
                .WrongCategory(.class, object) }
        
        let result = try mirror.children.flatMap {
            return ($0.label!, try interpret($0.value))
        }
        
        return Dictionary(uniqueKeysWithValues: result)
    }
    
    public static func interpretObjectWithNestedTypes<T:TCJSONCodable>(
        _ object: T)
        throws -> [String: Any] {
            
            let mirror = Mirror(reflecting: object)
            guard mirror.displayStyle == .class
                || mirror.displayStyle == .struct
                else { throw TCJSONReflectionError
                    .WrongCategory(.class, object) }
            
            return try applyMultiLevelCodingKeys(toObject: object)
    }
    
    /// Interprets an optional into a valid JSON object representation of it.
    ///
    /// - Parameter value: The optional to interpret.
    /// - Returns: A valid JSON object.
    /// - Throws: From passing as argument something that is not an optional.
    public static func interpretOptional(_ object: Any) throws -> Any {
        let mirror = Mirror(reflecting: object)
        
        guard
            mirror.displayStyle == .optional
            else { throw TCJSONReflectionError
                .WrongCategory(.optional, object) }
        
        if mirror.children.count == 0 { return Optional<Any>.none as Any }
        let (_, some) = mirror.children.first!
        return try interpret(some)
    }
    
    /// Interprets an array into a valid JSON object representation of it.
    ///
    /// - Parameter value: The array to interpret.
    /// - Returns: A valid JSON object.
    /// - Throws: From passing as argument something that is not an array.
    public static func interpretArray(_ array: Any) throws -> Any {
        let mirror = Mirror(reflecting: array)
        
        guard
            mirror.displayStyle == .collection,
            let arr = array as? [Any]
            else { throw TCJSONReflectionError
                .WrongCategory(.collection, array) }
        
        return try arr.map(interpret)
    }
    
    /// Interprets a dictionary into a valid JSON object representation of it.
    ///
    /// - Parameter value: The dictionary to interpret.
    /// - Returns: A valid JSON object.
    /// - Throws: From passing as argument something that is not a dictionary.
    public static func interpretDictionary(_ dict: Any) throws -> Any {
        let mirror = Mirror(reflecting: dict)
        
        guard
            mirror.displayStyle == .dictionary,
            let d = dict as? [String: Any]
            else { throw TCJSONReflectionError
                .WrongCategory(.dictionary, dict) }
        
        return try d.mapValues(interpret)
    }
    
    /// Checks if the values of two any objects are equal.
    ///
    /// - Parameters:
    ///   - a: Any int/double/bool/string/array/dictionary/2-tuple/object
    ///   - b: Any int/double/bool/string/array/dictionary/2-tuple/object
    /// - Returns: true if equal, false otherwise
    public static func equals(_ a: Any, _ b: Any) -> Bool {
        
        switch (isOptional(a), isOptional(b)) {
        // If both are optionals
        case (true, true):
            switch (isNil(a), isNil(b)) {
                // If both are nil = true
            case (true, true): return true
                // If only one is nil = false
            case (true, false): return false
            case (false, true): return false
                // If both are .some
            case (false, false): return equals(
                // forcedUnwrap both and recursion
                forcedUnwrap(a), forcedUnwrap(b))
            }
            
        // If only one is optional
        case (true, false):
            //If nil = false
            if isNil(a) { return false }
            //If some = forcedUnwrap and recursion
            return equals(forcedUnwrap(a), b)
        case (false, true):
            //If nil = false
            if isNil(b) { return false }
            //If some = forcedUnwrap and recursion
            return equals(forcedUnwrap(b), a)
        // If no optionals continue
        default: break
        }
        
        // Check types
        switch (a, b) {
        
        // If both arrays
        case (let x as [Any], let y as [Any]):
            // If both empty = true
            guard !x.isEmpty && !y.isEmpty
                // If only one empty = false
                else { return x.isEmpty && y.isEmpty }
            // If different count = false
            guard x.count == y.count else { return false }
            // Then compare elements
            return zip(x, y).map(equals).reduce(true) { $0 && $1 }
        
        // If both dicts
        case (let x as [String: Any], let y as [String: Any]):
            // If both empty = true
            guard !x.isEmpty && !y.isEmpty
                // If only one empty = false
                else { return x.isEmpty && y.isEmpty }
            // If different count = false
            guard x.count == y.count else { return false }
            // Then compare tuples (key, value)
            return zip(x, y).map(equals).reduce(true) { $0 && $1 }
        
        // If both tuples = equals elements
        case (let x as (Any, Any), let y as (Any, Any)):
            return equals(x.0, y.0) && equals(x.1, y.1)
            
        // If both values = compare them
        case (let x as Int, let y as Int): return x == y
        case (let x as Double, let y as Double): return x == y
        case (let x as Bool, let y as Bool): return x == y
        case (let x as String, let y as String): return x == y
        
        // If non-matching types = false
        case (_ as Bool, _): return false
        case (_, _ as Bool): return false
            
        case (_ as (Any, Any), _): return false
        case (_, _ as (Any, Any)): return false
            
        case (_ as [String: Any], _): return false
        case (_, _ as [String: Any]): return false
            
        case (_ as [Any], _): return false
        case (_, _ as [Any]): return false
            
        case (_ as Double, _): return false
        case (_, _ as Double): return false
            
        case (_ as Int, _): return false
        case (_, _ as Int): return false
            
        case (_ as String, _): return false
        case (_, _ as String): return false
            
        // If two objects
        case (let x, let y):
            guard
                // Interpret them
                let aInterpretedObject = try? interpret(x),
                let bInterpretedObject = try? interpret(y),
                // If only one a object = false
                let aObject = aInterpretedObject as? [String: Any],
                let bObject = bInterpretedObject as? [String: Any]
                else { return false }
            // Compare them as dicts.
            return equals(aObject, bObject)
        }
    }
    
    /// Returns true if any is optional.
    ///
    /// - Parameter mirror: you can pass directly a mirror to this function to avoid the generation of a new one inside it.
    /// - Returns: true if optional, false otherwise
    static func isOptional(
        _ any: Any,
        mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
        -> Bool {
            return mirror(any).displayStyle == .optional
    }
    
    /// Returns true if any is nil.
    ///
    /// - Parameter mirror: you can pass directly a mirror to this function to avoid the generation of a new one inside it.
    /// - Returns: true if nil, false otherwise
    static func isNil(
        _ any: Any,
        mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
        -> Bool {
            let m = mirror(any)
            guard m.displayStyle == .optional else { return false }
            return m.children.count == 0
    }
    
    /// Force unwrap a optional Any.
    ///
    /// - Parameter mirror: you can pass directly a mirror to this function to avoid the generation of a new one inside it.
    /// - Returns: true if optional, false otherwise
    public static func forcedUnwrap(
        _ any: Any,
        mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
        -> Any { return mirror(any).children.first!.value
    }
    
    /// Safely unwrap a optional Any to its value.
    /// Also recursevely unwrap double or n-optionals.
    ///
    /// - Parameter mirror: you can pass directly a mirror to this function to avoid the generation of a new one inside it.
    /// - Returns: true if optional, false otherwise
    public static func unwrapOptional(_ any: Any) -> Any {
        let mirror = Mirror.init(reflecting: any)
        guard mirror.displayStyle == .optional else { return any }
        guard mirror.children.count != 0 else { return Optional<Any>.none as Any }
        let internalValue = mirror.children.first!.value
        return unwrapOptional(internalValue)
    }
}

/// It's thrown from interpreting the inner values with the wrong func.
public enum TCJSONReflectionError: Error {
    public typealias ExpectedStyle = Mirror.DisplayStyle
    
    case WrongCategory(ExpectedStyle, Any)
    
    var localizedDescription: String {
        switch self {
        case .WrongCategory(let right, let wrongObj): return "The item that should be interpreted as a \"\(right)\" is a \"\(wrongObj)\" instead."
        }}}
