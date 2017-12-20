//
//  TCJSONCodable.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 09/12/2017.
//

import Foundation

public protocol TCJSONCodable: Codable {
    var json: TCJSON<Self> { get }
    
    init(fromData data: Data) throws
    init(fromJSONString string: String) throws
}

extension TCJSONCodable {
    public var json: TCJSON<Self> {
        return TCJSON<Self>(self)
    }
    
    public init(fromData data: Data) throws {
        self = try TCJSON(data).content()
    }

    public init(fromJSONString string: String) throws {
        let json = try TCJSON<Self>(jsonString: string)
        self = try json.content()
    }
}
