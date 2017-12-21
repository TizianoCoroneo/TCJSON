//
//  TCJSON.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 09/12/2017.
//

import Foundation

/// Utility wrapper for common `Codable` operations.
public struct TCJSON<Content: Codable>: Codable {
    private let _content: Content?
    private let _json: Data?
    
    /// Returns the model object.
    ///
    /// - Returns: The model object used to initialize this instance, or decoded from `Data`.
    /// - Throws: Rethrows from `JSONDecoder`.
    public func content() throws -> Content {
        if let content = _content { return content }
        return try JSONDecoder().decode(Content.self, from: _json!)
    }
    
    /// Returns `Data` corresponding to the content object encoded with `JSONEncoder`.
    ///
    /// - Returns: The `Data` object.
    /// - Throws: Rethrows from `JSONEncoder`.
    public func data() throws -> Data {
        if let json = _json { return json }
        return try JSONEncoder().encode(_content!)
    }
    
    /// Initialize from a model object that conforms to Codable.
    ///
    /// - Parameter content: Model object.
    public init(_ content: Content) {
        self._content = content
        self._json = nil
    }
    
    /// Initialize from a `JSONEncoded` `Data` object.
    ///
    /// - Parameter json: The input `Data`.
    public init(_ json: Data) {
        self._json = json
        self._content = nil
    }
    
    /// Initialize from a valid JSON formatted string. If the string is not valid, the exception will be thrown only when asking for `content()`.
    ///
    /// - Parameter jsonString: A string that contains valid JSON content.
    public init(jsonString: String) {
        let data = jsonString.data(using: .utf8)!
        self.init(data)
    }
    
    /// Do something with the JSON formatted as `Data`, and return a new `TCJSON` object.
    ///
    /// - Parameter f: The function gets `Data` and return a new `Content` for the new `TCJSON` object.
    /// - Returns: The new `TCJSON` object.
    /// - Throws: Rethrows from the application of `f` and the conversion in `Data` of the content.
    public func map<X>(
        data f: (Data) throws -> X)
        throws -> TCJSON<X> {
            
            return TCJSON<X>(try f(try data()))
    }
    
    /// Do something with the JSON formatted as `Content`, and return a new `TCJSON` object.
    ///
    /// - Parameter f: The function gets `Content` and return a new `Content` for the new `TCJSON` object.
    /// - Returns: The new `TCJSON` object.
    /// - Throws: Rethrows from the application of `f` and the conversion in `Content` of the content.
    public func map<X>(
        content f: (Content) throws -> X)
        throws -> TCJSON<X> {
            
            return TCJSON<X>(try f(try content()))
    }
    
    /// Do something with the JSON formatted as `Data`, and return a new `TCJSON` object.
    ///
    /// - Parameter f: The function gets `Data` and return a new `TCJSON` object.
    /// - Returns: The new `TCJSON` object returned by f.
    /// - Throws: Rethrows from the mapping of `f`, the conversion in `Data` of the content, and the flattening operation.
    public func bind<X>(
        data f: (Data) throws -> TCJSON<X>)
        throws -> TCJSON<X> {
            return try map(data: f).flatten()
//            return try f(try data())
    }
    
    /// Do something with the JSON formatted as `Content`, and return a new `TCJSON` object.
    ///
    /// - Parameter f: The function gets `Content` and return a new `TCJSON` object.
    /// - Returns: The new `TCJSON` object returned by f.
    /// - Throws: Rethrows from the mapping of `f`, the conversion in `Content` of the content, and the flattening operation.
    public func bind<X>(
        content f: (Content) throws -> TCJSON<X>)
        throws -> TCJSON<X> {
            return try map(content: f).flatten()
//            return try f(try content())
    }
    
    /// If the current `TCJSON` contains another `TCJSON` object (like `TCJSON<TCJSON<String>>`), get rid of the outer object and returns the internal one (like `(TCJSON<TCJSON<String>>) -> TCJSON<String>`).
    ///
    /// - Returns: The new internal TCJSON object.
    /// - Throws: Can throw `FlatteningError` if the swift type infer system fucks up. It shouldn't be possible to throw it.
    public func flatten<X: Codable>() throws -> TCJSON<X> {
        let content = try self.content()
        
        if let c = content as? TCJSON<X> { return c }
        if let s = self as? TCJSON<X> { return s }
        
        throw FlatteningError(fromType: Content.self, toType: X.self)
    }
    
    /// Applies a function to the `Data` content of a `TCJSON` object.
    ///
    /// - Parameter f: Function to be applied on `Data`.
    /// - Throws: Rethrows from the function application and the conversion to `Data`.
    public func apply(
        data f: (Data) throws -> ())
        throws {
            try f(try data())
    }
    
    /// Applies a function to the `Content` of a `TCJSON` object.
    ///
    /// - Parameter f: Function to be applied on `Content`.
    /// - Throws: Rethrows from the function application and the conversion to `Content`.
    public func apply(
        content f: (Content) throws -> ())
        throws {
            try f(try content())
    }
    
    /// Takes the content of two `TCJSON` objects, applies a function to them and creates a new TCJSON object from the result.
    ///
    /// - Parameters:
    ///   - x: `TCJSON` that provides the first argument of the function.
    ///   - y: `TCJSON` that provides the second argument of the function.
    ///   - closure: Function to be applied to the contents of the two `TCJSON`s.
    /// - Returns: The new `TCJSON` object with the content of the result of `f`.
    /// - Throws: Rethrows from initializing with content and from the two conversions to content.
    public static func zip<X, Y, Z: Codable>(
        x: TCJSON<X>,
        y: TCJSON<Y>,
        closure: (X, Y) throws -> Z)
        throws -> TCJSON<Z> {
            return try TCJSON<Z>(closure(try x.content(), try y.content()))
    }
    
    /// This error could occur when flattening a TCJSON which doesn't need flattening.
    struct FlatteningError<X, Y>: Error {
        var localizedDescription: String {
            return string
        }
        
        private let string: String
        
        init(fromType from: X.Type, toType to: Y.Type) {
            self.string = "Impossible casting from \(from) to \(to)"
        }
    }
}
