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
  
  public static func equals(_ a: Any, _ b: Any) -> Bool {
    
        if (isOptional(a) && isOptional(b)) {
            switch (isNil(a), isNil(b)) {
            case (true, true): return true
            case (true, false): return false
            case (false, true): return false
            case (false, false):
                return equals(forcedUnwrap(a), forcedUnwrap(b))
            }
        } else if isOptional(a) {
            if isNil(a) { return false }
            return equals(forcedUnwrap(a), b)
        } else if isOptional(b) {
            if isNil(b) { return false }
            return equals(a, forcedUnwrap(b))
        }
        
    switch (a, b) {
    case (let x as [Any], let y as [Any]):
      guard !x.isEmpty && !y.isEmpty
        else { return x.isEmpty && y.isEmpty }
      guard x.count == y.count else { return false }
      return zip(x, y).map(equals).reduce(true) { $0 && $1 }
    
    case (let x as [String: Any], let y as [String: Any]):
      guard !x.isEmpty && !y.isEmpty
        else { return x.isEmpty && y.isEmpty }
      guard x.count == y.count else { return false }
      return zip(x, y).map(equals).reduce(true) { $0 && $1 }
      
    case (let x as (Any, Any), let y as (Any, Any)):
      return equals(x.0, y.0) && equals(x.1, y.1)

    case (let x as Int, let y as Int): return x == y
    case (let x as Double, let y as Double): return x == y
    case (let x as Bool, let y as Bool): return x == y
    case (let x as String, let y as String): return x == y
      
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
      
//    case (let x as AnyHashable, let y as AnyHashable):
//      return x.hashValue == y.hashValue
        
    case (let x, let y):
      guard
        let aInterpretedObject = try? interpret(x),
        let bInterpretedObject = try? interpret(y),
        let aObject = aInterpretedObject as? [String: Any],
        let bObject = bInterpretedObject as? [String: Any]
        else { return false }
      return equals(aObject, bObject)
    }
  }
  
  static func isOptional(
    _ any: Any,
    _ mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
    -> Bool {
      return mirror(any).displayStyle == .optional
  }
  
  static func isNil(
    _ any: Any,
    _ mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
    -> Bool {
      let m = mirror(any)
      guard m.displayStyle == .optional else { return false }
      return m.children.count == 0
  }
  
  private static func forcedUnwrap(
    _ any: Any,
    _ mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
    -> Any { return mirror(any).children.first!.value
  }
  
  static func unwrapOptional(_ any: Any) -> Any {
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
