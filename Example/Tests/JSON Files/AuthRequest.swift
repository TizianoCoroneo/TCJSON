import Foundation
import TCJSON

struct AuthRequest: TCJSONCodable {
    let email: String
    let password: String
    let grantType: String
    let clientId: String
    let clientSecret: String
    private enum CodingKeys: String, CodingKey {
        case email
        case password
        case grantType = "grant_type"
        case clientId = "client_id"
        case clientSecret = "client_secret"
    }
}
