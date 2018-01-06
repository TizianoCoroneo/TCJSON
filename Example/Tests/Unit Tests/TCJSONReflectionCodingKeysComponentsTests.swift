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
        
        func candidates<T: Encodable>(_ xs: T) -> Mirror.CandidatesDictionary {
            return try! Mirror.getCandidates(
                forObject: try! Mirror.interpret(xs) as! [String : Any],
                comparingTo: try! Mirror.systemSerialize(xs) as! [String : Any])
        }
        
        describe("receiverHasUniqueCandidate") {
            
            context("with object with no coding keys") {
                let obj = TestClass()
                
                it("should return true") {
                    let candidateList = candidates(obj)
                    
                    candidateList.forEach({
                        let res = Mirror.receiverHasUniqueCandidate(
                            $0.key,
                            from: candidateList) || candidateList[$0.key]!.count == 0
                        expect(res).to(beTrue())
                    })
                }
            }
            
            context("with object with no key conflicts") {
                let obj = TestClassWithCodingKeys()
                
                it("should return true") {
                    let candidateList = candidates(obj)
                    
                    candidateList.forEach({
                        let res = Mirror.receiverHasUniqueCandidate(
                            $0.key,
                            from: candidateList) || candidateList[$0.key]!.count == 0
                        
                        expect(res).to(beTrue())
                    })
                }
            }
            
            context("with object with key conflicts") {
                let obj = TestClassWithExtemeCodingKeys()
                
                func shouldntConflict(_ key: String) -> Bool {
                    return key == "boolean3"
                        || key == "double3"
                        || key == "int3"
                        || key == "nilOptional"
                        || key == "nilOptional2"
                        || key == "nilOptional3"
                        || key == "array3"
                        || key == "object3"
                        || key == "dict3"
                        || key == "dict4"
                        || key == "dict5"
                        || key == "disappear1"
                        || key == "disappear2"
                }
                
                let candidateList = candidates(obj)
                
                func test(_ key: String, _ candidates: [String: [String]], _ success: Bool) {
                    
                    let res = Mirror.receiverHasUniqueCandidate(
                        key,
                        from: candidates)
                        || candidates.count == 0
                    
                    it("for \(key) returns \(success)") {
                        if success {
                            expect(res).to(beTrue())
                        } else {
                            expect(res).to(beFalse())
                        }
                    }
                }
                
                candidateList.map({
                    ($0.key, $0.value, shouldntConflict($0.key))
                }).forEach { test($0.0, candidateList, $0.2) }
            }
        }
        
        describe("candidateHasUniqueReceiver") {
            
            func check(
                _ cands: Mirror.CandidatesDictionary,
                _ success: Bool? = nil,
                _ successDict: [Mirror.Candidate: Bool]? = nil) {
                cands.forEach({ receiverPair in
                    receiverPair.value.forEach { cand in
                        let res = Mirror.candidateHasUniqueReceiver(
                            cand,
                            from: cands)
                    
                        let ok: Bool = success
                            ?? successDict?[cand] ?? true
                        
                        it("for \(receiverPair.key) returns \(ok)") {
                            if ok {
                                expect(res).to(beTrue())
                            } else {
                                expect(res).to(beFalse())
                            }
                        }
                    }
                })
            }
            
            context("with object with no coding keys") {
                let obj = TestClass()
                let candidateList = candidates(obj)
                
                check(candidateList, true)
            }
            
            
            context("with object with no key conflicts") {
                let obj = TestClassWithCodingKeys()
                let candidateList = candidates(obj)
                
                check(candidateList, true)
            }
            
            context("with object with key conflicts") {
                let obj = TestClassWithExtemeCodingKeys()
                
                func shouldntConflict(_ key: String) -> Bool {
                    return key == "boolean3"
                        || key == "double3"
                        || key == "int3"
                        || key == "nilOptional"
                        || key == "nilOptional2"
                        || key == "nilOptional3"
                        || key == "array3"
                        || key == "object3"
                        || key == "dict3"
                        || key == "dict4"
                        || key == "dict5"
                        || key == "disappear1"
                        || key == "disappear2"
                }
                
                let candidateList = candidates(obj)
                
                func test(_ key: String, _ candidates: [String: [String]], _ success: Bool) {
                    
                    let res = Mirror.receiverHasUniqueCandidate(
                        key,
                        from: candidates)
                        || candidates.count == 0
                    
                    it("for \(key) returns \(success)") {
                        if success {
                            expect(res).to(beTrue())
                        } else {
                            expect(res).to(beFalse())
                        }
                    }
                }
                
                candidateList.map({
                    ($0.key, $0.value, shouldntConflict($0.key))
                }).forEach { test($0.0, candidateList, $0.2) }
            }
        }
    }
}
