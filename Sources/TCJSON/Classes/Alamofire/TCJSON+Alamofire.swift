import Foundation
import Alamofire

/// Provides the encoding method when making requests using model objects.
public struct TCJSONRequestEncoding<T: TCJSONCodable>: ParameterEncoding {
    
    /**
     The key used in the request dictionary. To send directly a request with
     a model object, you must wrap it in a `[String: Any]` dictionary, like:
     ```
     [ "result": TestClass() ]
     ```
     `requestKey` is the key used in the dictionary (in this example: "result").
     */
    public let requestKey: String
    
    /// Initialize the encoding object, optionally providing a custom `requestKey`.
    /// See `requestKey` for more information.
    ///
    /// - Parameter key: The key to adopt in the request's parameters dictionary.
    public init(withRequestKey key: String = "request") {
        self.requestKey = key
    }
    
    /**
     Takes a URLRequest and converts the model object in the parameters dictionary
     into a new parameters dictionary.
     
     - Parameters:
     - urlRequest: The endpoint of the request.
     - parameters: The parameters dict. For TCJSON models is `[ "result": TestClass() ]`.
     - Returns: The modified URLRequest with the new parameters dict.
     - Throws: From the conversion of the `uri` in `URLRequest`.
     */
    public func encode(
        _ urlRequest: URLRequestConvertible,
        with parameters: Parameters?) throws -> URLRequest {
        let urlRequest = try urlRequest.asURLRequest()
        
        guard
            let par = parameters,
            let model = par[requestKey] as? T
            else { return urlRequest }
        
        return try URLEncoding
            .methodDependent
            .encode(
                urlRequest,
                with: try model.json.codingKeyAwareDictionary())
    }
}

extension TCJSONCodable {
    /// Returns the correct parameter dictionary for Alamofire and the corresponding encoding object.
    public var af_encoded: ([String: Self], TCJSONRequestEncoding<Self>) {
        let encoding = TCJSONRequestEncoding<Self>()
        return ([encoding.requestKey: self], encoding)
    }
}

extension DataRequest {
    /**
     Adds a handler to be called once the request has finished. This handler receives directly a converted model object.
     
     ```swift
     SessionManager.default
     	.request(
     		"http://api.test.com/api/auth",
     		method: .post,
     		tcjson: request,
     		headers: nil)
     	.responseTCJSON {
     		(auth: DataResponse<AuthResponse>) in
     
    	 	guard auth.error == nil else {
            fail("Error = \(auth.error?.localizedDescription ?? "nil")")
     			return
	     	}
     
    	 	response = auth.result.value
     }
     ```
     
     - parameter queue: Dispatch queue in which executing the request.
     - parameter options: The JSON serialization reading options. Defaults to `.allowFragments`.
     - parameter completionHandler: A closure to be executed once the request has finished.
     - returns: The request.
     **/
    @discardableResult public func responseTCJSON<T: TCJSONCodable>(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self {
            
            return responseJSON(
                queue: queue,
                options: options,
                completionHandler: { json in
                    func generate(error: Error) -> DataResponse<T> {
                        if TCJSONOptions.isVerbose {
                            print("TCJSON Error: \(error.localizedDescription)\n\nDetails: \(error)")
                        }
                        
                        return generate(Result.failure(error))
                    }
                    
                    func generate(
                        _ result: Result<T>) -> DataResponse<T> {
                        if TCJSONOptions.isVerbose {
                            print("TCJSON Result:\n\(result)\n\nFrom:\n\(json)")
                        }
                        
                        return DataResponse(
                            request: json.request,
                            response: json.response,
                            data: json.data,
                            result: result)
                    }
                    
                    guard let value = json.result.value else {
                        completionHandler(
                            generate(error: json.result.error!))
                        return
                    }
                    
                    do {
                        let object = try T(fromJSON: value)
                        
                        completionHandler(
                            generate(Result.success(object)))
                    } catch {
                        completionHandler(
                            generate(error: error))
                    }
            })
    }
}

// MARK: - Extension for TCJSONCodable objects compatible requests.
extension SessionManager {
    /**
     Creates a `DataRequest` using the default `SessionManager` to retrieve the contents of the specified `url`,
     `method`, `parameters`, `encoding` and `headers`.
     
     ```swift
     SessionManager.default
         .request(
             "http://api.test.com/api/auth",
             method: .post,
             tcjson: request,
             headers: nil)
         .responseTCJSON {
             (auth: DataResponse<AuthResponse>) in
     
             guard auth.error == nil else {
                 fail("Error = \(auth.error?.localizedDescription ?? "nil")")
                 return
             }
     
             response = auth.result.value
     }
     ```
     
     - parameter url:        The URL.
     - parameter method:     The HTTP method. `.get` by default.
     - parameter tcjson:     The model object TCJSONCodable to use as parameter.
     - parameter headers:    The HTTP headers. `nil` by default.
     - returns: The created `DataRequest`.
     **/
    public func request<T: TCJSONCodable>(
        _ url: URLConvertible,
        method: HTTPMethod,
        tcjson: T,
        headers: HTTPHeaders?
        ) -> DataRequest {
        let (parameters, encoding) = tcjson.af_encoded
        
        return request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers)
    }
}
