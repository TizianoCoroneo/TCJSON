
import Moya

/// `TargetType` used to initialize the `MoyaProvider`. Gets the requests values from the model itself.
///
/// - requestObject: a call that pass a model object to the API.
public enum TCJSONService: TargetType {
    case requestObject(TCJSONMoyaRequestModel)
    
    /// Base URL of the request: for "https://facebook.com/api/something" is "https://facebook.com/"
    public var baseURL: URL {
        switch self {
        case .requestObject(let v):
            return v.baseURL
        }
    }
    
    /// Path of the request: for "https://facebook.com/api/something" is "api/something"
    public var path: String {
        switch self {
        case .requestObject(let v):
            return v.path
        }
    }
    
    /// The HTTP method to use for this request.
    public var method: Moya.Method {
        switch self {
        case .requestObject(let v):
            return v.method
        }
    }
    
    /// Sample response of a successfull request for testing purposes.
    public var sampleData: Data {
        switch self {
        case .requestObject(let v):
            return v.sampleData
        }
    }
    
    /// Kind of data retrieving task that the request should execute.
    public var task: Task {
        switch self {
        case .requestObject(let v):
            return v.task
        }
    }
    
    /// HTTP headers of the request.
    public var headers: [String : String]? {
        switch self {
        case .requestObject(let v):
            return v.headers
        }
    }
}
