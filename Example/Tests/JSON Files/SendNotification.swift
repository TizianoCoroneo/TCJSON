import Foundation
import TCJSON

struct SendNotification: TCJSONCodable {
    
    let notificationType: Int
    
    struct Receiver: TCJSONCodable {
        let userId: Int
        let language: String
    }
    
    let receivers: [Receiver]
}
