//
//  AlamofireTests.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 23/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import TCJSON
import OHHTTPStubs
import Alamofire

class AlamofireSpec: QuickSpec {
    override func spec() {
        describe("Alamofire") {
            context("when trying post") {
                var response: AuthResponse? = nil
                let request = AuthRequest.init(
                    email: "test@lol.com",
                    password: "test",
                    grantType: "test",
                    clientId: "test",
                    clientSecret: "random")
                
                beforeEach {
                    stub(condition: isHost("api.test.com") && isPath("/api/auth")) { _ in
                        let stubPath = OHPathForFile("AuthResponse.json", type(of: self))
                        return fixture(
                            filePath: stubPath!,
                            headers: ["Content-Type":"application/json"])
                    }
                }
                
                afterEach {
                    OHHTTPStubs.removeAllStubs()
                }
                
                beforeEach {
                    response = nil
                    
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
                }
                
                it("accepts a request model object") {
                    expect(response).toNotEventually(beNil())
                }
                
                it("returns a response model object") {
                    expect(response?.tokenType).toEventually(equal("bearer"))
                }
            }
            
            context("when trying get") {
                let result1 = Categories.Result(
                    id: "1",
                    parentId: nil,
                    name: "Software Development")
                let result2 = Categories.Result(
                    id: "3",
                    parentId: nil,
                    name: "Administration")
                let expected = Categories(result: [result1, result2])
                
                var v: Categories? = nil
                
                beforeEach {
                    stub(condition: isHost("api.test.com") && isPath("/categories")) { _ in
                        let stubPath = OHPathForFile("Categories.json", type(of: self))
                        return fixture(
                            filePath: stubPath!,
                            headers: ["Content-Type":"application/json"])
                    }
                    
                    v = nil
                    
                    Alamofire.request(
                        "https://api.test.com/categories",
                        method: .get)
                        .validate()
                        .responseTCJSON { (cat: DataResponse<Categories>) in
                            expect(cat.result.value).notTo(beNil())
                            expect(cat.result.error).to(beNil())
                            
                            guard let value = cat.result.value else { return }
                            
                            v = value
                    }
                }
                
                afterEach {
                    OHHTTPStubs.removeAllStubs()
                }
                
                it("accepts a request model object") {
                    expect(v).toEventuallyNot(beNil())
                }
                
                it("returns a valid model object.") {
                    expect(v).toEventually(equal(expected))
                }
            }
        }
    }
}
