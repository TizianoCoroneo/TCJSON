import Foundation
import TCJSON

struct Categories: TCJSONCodable {
    struct Result: TCJSONCodable {
        let id: String
        let parentId: Int?
        let name: String
    }
    let result: [Result]
}

extension Categories: Equatable {
    static func ==(_ a: Categories, _ b: Categories) -> Bool {
        return zip(a.result, b.result).reduce(true) {
            acc, x in
            
            return acc
            && (x.0.id == x.1.id)
            && (x.0.name == x.1.name)
            && (x.0.parentId == x.1.parentId)
        }
    }
}
