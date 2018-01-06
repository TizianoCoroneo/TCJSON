//
//  TCJSONReflectionCodingKeysTests.swift
//  TCJSON_Tests
//
//  Created by Tiziano Coroneo on 06/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import TCJSON
import Nimble
import Quick

class TCJSONReflectionCodingKeysComponentsSpec: QuickSpec {
    override func spec() {
        
        describe("Has Unique bindings") {
            
            func candidates<T: Encodable>(_ xs: T) -> Mirror.CandidatesDictionary {
                return try! Mirror.getCandidates(
                    forObject: try! Mirror.interpret(xs) as! [String : Any],
                    comparingTo: try! Mirror.systemSerialize(xs) as! [String : Any])
            }
            
            context("when provided an object without coding keys") {
                let obj = TestClass()
                
                it("should return true") {
                    let candidateList = candidates(obj)
                    
                    let result = candidateList.map({
                        return Mirror.hasUniqueBinding(
                            $0.key,
                            inList: candidateList) || candidateList[$0.key]!.count == 0
                    }).reduce(true, { $0 && $1 })
                    
                    expect(result).to(beTrue())
                }
            }
            
            context("when provided an object with no key conflicts") {
                let obj = TestClassWithCodingKeys()
                
                it("should return true") {
                    let candidateList = candidates(obj)
                    
                    print("\nlist = \(candidateList)")
                    
                    candidateList.forEach({
                        let res = Mirror.hasUniqueBinding(
                            $0.key,
                            inList: candidateList) || candidateList[$0.key]!.count == 0
                        
                        expect(res).to(beTrue())
                    })
                }
            }
        }
        
    }
}
