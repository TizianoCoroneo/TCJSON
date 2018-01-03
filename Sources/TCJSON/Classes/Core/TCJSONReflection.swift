//
//  TCJSONReflection.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 02/01/2018.
//

import Foundation

extension Mirror {
    
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
}

/// It's thrown from interpreting the inner values with the wrong func.
public enum TCJSONReflectionError: Error {
    public typealias ExpectedStyle = Mirror.DisplayStyle
    
    case WrongCategory(ExpectedStyle, Any)
    
    var localizedDescription: String {
        switch self {
        case .WrongCategory(let right, let wrongObj):
            return "The item that should be interpreted as a \"\(right)\" is a \"\(wrongObj)\" instead."
        }
    }
}
