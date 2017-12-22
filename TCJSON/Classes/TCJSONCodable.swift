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
}
