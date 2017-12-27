//
//  TCJSONMoya.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 23/12/2017.
//

import Foundation
import Moya
import Result

/// Defines the necessary options for the Moya request.
public protocol TCJSONMoyaRequestModel {
    var baseURL: URL { get }
    var path: String { get }
    var method: Moya.Method { get }
    var sampleData: Data { get }
    var task: Moya.Task { get }
    var validate: Bool { get }
    var headers: [String: String]? { get }
}

/// Sub protocol of `TCJSONCodable` that provides also the necessary Data to make the request with Moya.
public protocol TCJSONMoya: TCJSONMoyaRequestModel, TCJSONCodable {}


/// Utility typealias to shorten the response type.
public typealias ResponseObject<A: TCJSONCodable> = Result<TCJSON<A>.Response, MoyaError>


// MARK: - TCJSON Response object definition
extension TCJSON where Content: TCJSONCodable {
    
    /// Type of the completion block of `responseTCJSON`.
    public typealias Completion = (_ result: Result<Response, MoyaError>) -> Void
    
    /// This is the type returned in the completion block for `responseTCJSON` in case of success.
    public final class Response {
        public let statusCode: Int
        public let result: Content
        public let request: URLRequest?
        public let response: HTTPURLResponse?
        
        /// Initialize a new `Response`.
        public init(
            statusCode: Int,
            result: Content,
            request: URLRequest? = nil,
            response: HTTPURLResponse? = nil) {
            self.statusCode = statusCode
            self.result = result
            self.request = request
            self.response = response
        }
        
        /// A text description of the `Response`.
        public var description: String {
            return "Status Code: \(statusCode), Result: \(result)"
        }
        
        /// A text description of the `Response`. Suitable for debugging.
        public var debugDescription: String {
            return description
        }
    }
}

// MARK: - Default implementation of the `TCJSONMoya` request objects.
public extension TCJSONMoyaRequestModel {
    public var method: Moya.Method {
        return .post
    }
    
    public var validate: Bool {
        return false
    }
}

// MARK: - Default implementation of the `TCJSONMoya` request objects. Needs TCJSONCodable conformance.
public extension TCJSONMoya {
    public var task: Moya.Task {
        return Moya.Task.requestJSONEncodable(self)
    }
}

extension MoyaProvider {
    /// Designated request-making method. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    public func request<A: TCJSONCodable>(
        _ target: Target,
        callbackQueue: DispatchQueue? = .none,
        progress: ProgressBlock? = .none,
        completionObject: @escaping TCJSON<A>.Completion) -> Cancellable {
        
        return request(
            target,
            callbackQueue: callbackQueue,
            progress: progress) { result in
                let newResult = result.flatMap { res in
                    return Result<TCJSON.Response, MoyaError>.init {
                        () throws -> TCJSON<A>.Response in
                        return TCJSON<A>.Response.init(
                            statusCode: res.statusCode,
                            result: try A.init(fromData: res.data),
                            request: res.request,
                            response: res.response)
                    }
                }
                
                completionObject(newResult)
        }
    }
}
