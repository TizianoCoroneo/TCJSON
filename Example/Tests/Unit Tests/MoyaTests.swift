//
//  MoyaTests.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 23/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import TCJSON
import Moya
import Result

extension AuthRequest: TCJSONMoya {
    var baseURL: URL {
        return URL(string: "http://www.api.test.com/")!
    }
    
    var path: String {
        return "auth"
    }
    
    var sampleData: Data {
        return """
        {
        "access_token": "test",
        "expires_in": 3600,
        "token_type": "bearer",
        "scope": null,
        "refresh_token": "test"
        }
        """.data(using: .utf8)!
    }
    
    var headers: [String : String]? {
        return nil
    }
}

extension AuthResponse: Equatable {
    static func ==(_ a: AuthResponse, _ b: AuthResponse) -> Bool {
        return a.accessToken == b.accessToken
            && a.expiresIn == b.expiresIn
            && a.tokenType == b.tokenType
            && a.scope == b.scope
            && a.refreshToken == b.refreshToken
    }
}

class MoyaSpec: QuickSpec {
    override func spec() {
        describe("Moya") {
            var provider: MoyaProvider<TCJSONService>!
            
            let requestObject = AuthRequest.init(
                email: "test@test.com",
                password: "test",
                grantType: "bearer",
                clientId: "lol",
                clientSecret: "lol")
            
            beforeSuite {
                provider = MoyaProvider<TCJSONService>.init(
                    stubClosure: MoyaProvider.immediatelyStub)
            }
            
            afterSuite {
                provider = nil
            }
            
            context("when trying post") {
                var response: AuthResponse! = nil
                let expected = AuthResponse.init(
                    accessToken: "test",
                    expiresIn: 3600,
                    tokenType: "bearer",
                    scope: nil,
                    refreshToken: "test")
                
                beforeEach {
                    _ = provider.request(
                        TCJSONService.requestObject(requestObject), completionObject: {
                            (res: ResponseObject<AuthResponse>) in
                            
                            guard
                                let value = res.value?.result
                                else { return }
                            
                            debugPrint(res.value!.debugDescription)
                            
                            response = value
                            
                    })
                }
                
                it("accepts a request model object") {
                    expect(response).toEventuallyNot(beNil())
                }
                
                it("returns a correct response model object") {
                    expect(response).toEventually(equal(expected))
                }
            }
            
        }
    }
}

