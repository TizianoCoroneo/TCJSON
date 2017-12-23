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
        "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpZCI6IjM5Njg5MTA2YmFjYjcwZGNkZjFlY2RkMjNiNGM2ZmZmNzc4ODIzZWIiLCJqdGkiOiIzOTY4OTEwNmJhY2I3MGRjZGYxZWNkZDIzYjRjNmZmZjc3ODgyM2ViIiwiaXNzIjoiIiwiYXVkIjoiZnJsX2FwaSIsInN1YiI6IjMiLCJleHAiOjE1MTM5Nzk1ODksImlhdCI6MTUxMzk3NTk4OSwidG9rZW5fdHlwZSI6ImJlYXJlciIsInNjb3BlIjpudWxsfQ.A0Fx33M_XW5i46LyYi-JBp2_kd9yVf2KRi3f9FWMZaIKCZbpsVleNKrRi4kw78Yg6HgUreWRkcyOhSB_btw3UHbsl-l1RLvEibSPIdi1mFfRQoPIrMAieKjUVhdJ3gU1drZvAHZTKdPYvDRdPhpfgPMykHArv7fvWtwkNhad0iZ7gAlYncbesL-5fHvWyHP8LxBEdnAysIm-AhBzLDh2bvjlofAayEzFriTSOscmKJjWR125QZXggQWMtnw667DKx_iEs1-UFLaMd8HbBCOAPtFCmV3kK0yuzaRMJb8d70dmGgHW8TqZsXN_vGH6VRvJXShRa91JlYfGpX87_vFoaQ",
        "expires_in": 3600,
        "token_type": "bearer",
        "scope": null,
        "refresh_token": "e8ae5e32a2d58d35bf7bcd1f8024b902586baad5"
        }
        """.data(using: .utf8)!
    }
    
    var headers: [String : String]? {
        return nil
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
            
            context("when trying post") {
                it("accepts a request model object") {
                    var response: AuthResponse! = nil
                    _ = provider.request(
                        TCJSONService.requestObject(requestObject),
                        completionObject: { (res: Result<TCJSON<AuthResponse>.Response, MoyaError>) in
                            guard let value = res.value?.result else { return }
                            
                            response = value
                    })
                }
            }
            
            context("when trying get") {
                it("returns a valid model object.") {
                }
            }
        }
    }
}

