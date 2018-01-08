//
//  TCJSONCodable.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 09/12/2017.
//

import Foundation

/// `TCJSONCodable` extends `Codable` and provides access to the correpsoding `TCJSON` object and two utility initializers: `init(fromData:)` and `init(fromJSONString:)`
public protocol TCJSONCodable: Codable {
    /// The TCJSON object. Every `TCJSONCodable` gets one.
    var json: TCJSON<Self> { get }
    
    /// Initialize the model object from `Data` that represents it, using `JSONDecoder`.
    ///
    /// - Parameter data: The `Data` object.
    /// - Throws: Rethrows from the `JSONDecoder` `decode` method.
    init(fromData data: Data) throws
    
    /// Initialize the model object from a `String` that represents it, using `JSONDecoder` after encoding the string in utf8.
    ///
    /// - Parameter data: The JSON formatted `String`.
    /// - Throws: Rethrows from the `JSONDecoder` `decode` method.
    init(fromJSONString string: String) throws
    
    /// Initialize the model object from a JSON object (like the dictionary method but compatible also with plain values), that represents it, using `JSONDecoder` after encoding the string in utf8.
    ///
    /// - Parameter data: The JSON object.
    /// - Throws: Rethrows from the JSONSerialization and from the `JSONDecoder` `decode` method.
    init(fromJSON json: Any) throws
    
    /// Initialize the model object from a `[String: Any]` dictionary that represents it, using `JSONDecoder` after encoding the dictionary as `Data`.
    ///
    /// - Parameter data: The JSON object's dictionary.
    /// - Throws: Rethrows from the JSONSerialization and from the `JSONDecoder` `decode` method.
    init(fromDictionary dict: [String: Any?]) throws
    
    func codingKeysForNestedObject() throws -> [String : [String : String]]
}

// MARK: - Default implementations of `TCJSONCodable`
public extension TCJSONCodable {
    /// Just initialize it from the content of the model.
    public var json: TCJSON<Self> {
        return TCJSON<Self>(self)
    }
    
    /// Initialize a `TCJSON` object from `Data` and initialize `self` with it.
    ///
    /// - Parameter data: The `Data` object.
    /// - Throws: Rethrows from the TCJSON conversion from `Data` to `Content`
    public init(fromData data: Data) throws {
        self = try TCJSON(data).content()
    }
    
    /// Initialize a `TCJSON` object from a `String` and initialize `self` with it.
    ///
    /// - Parameter data: The JSON formatted `String`.
    /// - Throws: Rethrows from the TCJSON conversion from `Data` to `Content`
    public init(fromJSONString string: String) throws {
        let json = TCJSON<Self>(jsonString: string)
        self = try json.content()
    }
    
    /// Initialize a 'TCJSON' object from a JSON object.
    ///
    /// - Parameter dict: A valid JSON object.
    /// - Throws: Rehrows from serializing the object into `Data` and from initializing from `Data`.
    public init(fromJSON json: Any) throws {
        let jsonData = try JSONSerialization.data(
            withJSONObject: json, options: [])
        try self.init(fromData: jsonData)
    }
    
    /// Initialize a 'TCJSON' object from a `Dictionary` that describes a JSON object, like:
    ///
    /// [ "name": "Philipp",
    ///   "surname": "Schade",
    ///   "age": 31,
    ///   "helicopterRide": null
    /// ]
    ///
    /// - Parameter dict: A valid JSON object represented as a dictionary.
    /// - Throws: Rehrows from serializing the dictionary into `Data` and from initializing from `Data`.
    public init(fromDictionary dict: [String: Any?]) throws {
        try self.init(fromJSON: dict)
    }
    
    func codingKeysForNestedObject()
        throws -> [String : [String : String]] {
            return [:]
    }
    
    func codingKeys<T: TCJSONCodable>(
        forObject obj: T) throws -> [String: String] {
        return try TCJSONReflection.codingKeysLabels(inObject: obj)
    }
}
