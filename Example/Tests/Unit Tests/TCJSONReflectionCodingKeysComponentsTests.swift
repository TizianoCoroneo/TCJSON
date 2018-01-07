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
        
        func check(
            _ f: (String?, String?, TCJSONReflection.CandidatesDictionary) -> Bool,
            _ cands: TCJSONReflection.CandidatesDictionary,
            _ success: Bool? = nil,
            _ successPredicate: ((String, String) -> Bool)? = nil) {
            
            cands.forEach({ receiverPair in
                let rec = receiverPair.key
                receiverPair.value.forEach { cand in
                    
                    let res = f(rec, cand, cands)
                    
                    let ok: Bool = success
                        ?? successPredicate?(rec, cand) ?? false
                    
                    it("for \(rec), \(cand) returns \(ok)") {
                        if ok {
                            expect(res).to(beTrue())
                        } else {
                            expect(res).to(beFalse())
                        }
                    }
                }
            })
        }
        
        func candidates<T: Encodable>(_ xs: T) -> TCJSONReflection.CandidatesDictionary {
            return TCJSONReflection.getCandidates(
                forObject: try! TCJSONReflection.interpret(xs) as! [String : Any],
                comparingTo: try! TCJSONReflection.systemSerialize(xs) as! [String : Any])
        }
        
        describe("receiverHasUniqueCandidate") {
            let function: (String?, String?, TCJSONReflection.CandidatesDictionary) -> Bool = {
                rec, _, ls in
                guard let rec = rec else { return false }
                return TCJSONReflection.receiverHasUniqueCandidate(rec, from: ls)
            }
            
            context("with object with no coding keys") {
                let obj = TestClass()
                let candidateList = candidates(obj)
                
                check(function, candidateList, true)
            }
            
            
            context("with object with no key conflicts") {
                let obj = TestClassWithCodingKeys()
                let candidateList = candidates(obj)
                
                check(function, candidateList, true)
            }
            
            context("with object with key conflicts") {
                let obj = TestClassWithExtemeCodingKeys()
                
                func shouldntConflict(
                    _ rec: String,
                    _ cand: String) -> Bool {
                    return rec == "boolean3"
                        || rec == "double3"
                        || rec == "int3"
                        || rec == "nilOptional"
                        || rec == "nilOptional2"
                        || rec == "nilOptional3"
                        || rec == "array3"
                        || rec == "object3"
                        || rec == "dict3"
                        || rec == "dict4"
                        || rec == "dict5"
                        || rec == "disappear1"
                        || rec == "disappear2"
                        || rec == "same"
                        || rec == "same2"
                        || rec == "same3"
                }
                
                let candidateList = candidates(obj)
                check(function, candidateList, nil, shouldntConflict)
            }
        }
        
        describe("candidateHasUniqueReceiver") {
            let function: (String?, String?, TCJSONReflection.CandidatesDictionary) -> Bool = {
                rec, cand, ls in
                guard let cand = cand else { return false }
                return TCJSONReflection.candidateHasUniqueReceiver(
                    cand,
                    from: ls)
            }
            
            context("with object with no coding keys") {
                let obj = TestClass()
                let candidateList = candidates(obj)
                
                check(function, candidateList, true)
            }
            
            
            context("with object with no key conflicts") {
                let obj = TestClassWithCodingKeys()
                let candidateList = candidates(obj)
                
                check(function, candidateList, true)
            }
            
            context("with object with key conflicts") {
                let obj = TestClassWithExtemeCodingKeys()
                
                func shouldntConflict(
                    _ rec: String,
                    _ cand: String) -> Bool {
                    return cand == "correct_double3"
                        || cand == "correct_int3"
                        || cand == "correct_array3"
                        || cand == "correct_nilOptional3"
                        || cand == "correct_object3"
                        || cand == "correct_dict3"
                        || cand == "correct_dict4"
                        || cand == "correct_dict5"
                        || cand == "same"
                        || cand == "same2"
                        || cand == "same3"
                        || cand == "nilOptional"
                        || cand == "nilOptional2"
                }
                
                let candidateList = candidates(obj)
                
                check(function, candidateList, nil, shouldntConflict)
            }
        }
        
        describe("isUniqueBinding") {
            
            func check(
                _ cands: TCJSONReflection.CandidatesDictionary,
                _ success: Bool? = nil,
                _ successPredicate: ((String) -> Bool)? = nil) {
                cands.forEach({ receiverPair in
                    let rec = receiverPair.key
                    receiverPair.value.forEach { cand in
                        let res = TCJSONReflection.isUniqueBinding(
                            rec, cand, inList: cands)
                        
                        let ok: Bool = success
                            ?? successPredicate?(cand) ?? true
                        
                        it("for \(cand) returns \(ok)") {
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
                    return key == "correct_double3"
                        || key == "correct_int3"
                        || key == "correct_array3"
                        || key == "correct_nilOptional3"
                        || key == "correct_object3"
                        || key == "correct_dict3"
                        || key == "correct_dict4"
                        || key == "correct_dict5"
                        || key == "same"
                        || key == "same2"
                        || key == "same3"
                        || key == "nilOptional"
                        || key == "nilOptional2"
                }
                
                let candidateList = candidates(obj)
                
                check(candidateList, nil, shouldntConflict)
            }
        }
    }
}
