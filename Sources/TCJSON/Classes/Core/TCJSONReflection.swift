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
  
  public static func equals(_ val1: Any, _ val2: Any) -> Bool {
    
    if (isOptional(val1) && isOptional(val2)) {
      switch (isNil(val1), isNil(val2)) {
      case (true, true): return true
      case (true, false): return false
      case (false, true): return false
      case (false, false):
        return equals(try! internalUnwrap(val1), try! internalUnwrap(val2))
      }
    } else if isOptional(val1) {
      if isNil(val1) { return false }
      return equals(try! internalUnwrap(val1), val2)
    } else if isOptional(val2) {
      return equals(val2, val1)
    }
    
    let a = val1
    let b = val2
    
    switch (a, b) {
    case (let a as [Any], let b as [Any]):
      return zip(a, b).map(equals).reduce(true) { $0 && $1 }
    case (let a as [String: Any], let b as [String: Any]):
      return zip(a, b).map(equals).reduce(true) { $0 && $1 }
    case (let a as (Any, Any), let b as (Any, Any)):
      return equals(a.0, b.0) && equals(a.1, b.1)
    case (_ as AnyHashable, _ as [Any]): return false
    case (_ as [Any], _ as AnyHashable): return false
      
    case (let a as Int, let b as Int):
      return a == b
      
    case (let a as Double, let b as Double):
      return a == b
      
    case (let a as Bool, let b as Bool):
      return a == b
    case (_ as Bool, _): return false
    case (_, _ as Bool): return false
      
    case (let a as String, let b as String):
      return a == b
    case (_ as String, _): return false
    case (_, _ as String): return false
      
    case (let a as AnyHashable, let b as AnyHashable):
      return a.hashValue == b.hashValue
    case (let a, let b):
      let aMirror = Mirror.init(reflecting: a)
      let bMirror = Mirror.init(reflecting: b)
      
      if isNil(a, { _ in aMirror }) || isNil(b, { _ in bMirror }) {
        return isNil(a, { _ in aMirror }) && isNil(b, { _ in bMirror }) }
      
      let a2 = isOptional(a, { _ in aMirror })
        ? try! internalUnwrap(a, { _ in aMirror })
        : a
      let b2 = isOptional(b, { _ in bMirror })
        ? try! internalUnwrap(b, { _ in bMirror })
        : b
      
      if isOptional(a) {
        let a2 = try! internalUnwrap(a, { _ in aMirror })
        if isOptional(b) {
          let b2 = try! internalUnwrap(b, { _ in bMirror })
          return equals(a2, b2)
        } else {
          return equals(a2, b)
        }
      } else if isOptional(b) {
        let b2 = try! internalUnwrap(a, { _ in bMirror })
        if isOptional(a) {
          let a2 = try! internalUnwrap(a, { _ in aMirror })
          return equals(a2, b2)
        } else {
          return equals(a, b2)
        }
      }
      
      guard let aObject = try? interpret(a2) as? [String: Any] else { return false }
      guard let bObject = try? interpret(b2) as? [String: Any] else { return false }
      return equals(aObject as? Any, bObject as? Any)
    }
  }
  
  public static func isOptional(
    _ any: Any,
    _ mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
    -> Bool {
      return mirror(any).displayStyle == .optional
  }
  
  public static func isNil(
    _ any: Any,
    _ mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) })
    -> Bool {
      let m = mirror(any)
      guard m.displayStyle == .optional else { return false }
      return m.children.count == 0
  }
  
  public static func internalUnwrap(
    _ any: Any,
    _ mirror: (Any) -> (Mirror) = { Mirror(reflecting: $0) }) throws
    -> Any {
      let m = mirror(any)
      
      guard !isNil(any, { _ in m })
      else { throw NSError(domain: "Nil optional unwrap", code: 420, userInfo: nil) }
      
      return m.children.first!.value
  }
  
  private static func flattenOptional(_ any: Any) -> Any {
    let mirror = Mirror.init(reflecting: any)
    guard mirror.displayStyle == .optional else { return any }
    guard mirror.children.count != 0 else { return Optional<String>.none as Any }
    let internalMirror = Mirror.init(reflecting: mirror.children.first!.value)
    guard internalMirror.displayStyle == .optional else { return any }
    return mirror.children.first!.value
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
