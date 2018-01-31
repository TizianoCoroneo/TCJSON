//
//  TCJSONOptions.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 31/01/2018.
//

import Foundation

public struct TCJSONOptions {

    /// Encoder and Decoder couple used by `TCJSON` when transforming the data in other forms. Defaults to `JSONEncoder`.
    public static var defaultEncoder = JSONEncoder()
    public static var defaultDecoder = JSONDecoder()

    /// Set this to `true` if you want TCJSON to log every data conversion.
    public static var isVerbose: Bool = false
}
