// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import TCJSON

class TCJSONReflectionSpec: QuickSpec {
    override func spec() {
        describe("TCJSONReflection") {
            
            context("checking optionals as Any") {
                
                it("can check if it is optional") {
                    let result: Bool = TCJSONReflection.isOptional(
                        Optional<Any>.some(
                            "sss" as Any)
                            as Any)
                    
                    expect(result).toEventually(beTrue())
                }
                
                it("can check if it is double optional") {
                    let result = TCJSONReflection.isOptional(
                        Optional<Any>.some(
                            Optional<Any>.some(
                                "sss" as Any)
                                as Any)
                            as Any)
                    expect(result).to(beTrue())
                }
                
                it("can check if it is not optional") {
                    let result = TCJSONReflection.isOptional(
                        "sss" as Any)
                    expect(result).to(beFalse())
                }
                
                it("can check if a nil is optional") {
                    let result = TCJSONReflection.isOptional(
                        Optional<Any>.none as Any)
                    expect(result).to(beTrue())
                }
                
                it("can check if it is nil") {
                    let result = TCJSONReflection.isNil(
                        Optional<Any>.none as Any)
                    expect(result).to(beTrue())
                }
                
                it("can check if it is double optional") {
                    let result = TCJSONReflection.isNil(
                        Optional<Any>.some(
                            Optional<Any>.none as Any) as Any)
                    expect(result).to(beFalse())
                }
                
                it("can check if it is not nil") {
                    let result = TCJSONReflection.isNil(
                        "sss" as Any)
                    expect(result).to(beFalse())
                }
                
            }
            context("when throws") {
                it("provides adeguate description") {
                    var result = ""
                    do {
                        throw TCJSONReflectionError
                            .WrongCategory(
                                .class,
                                TestClass())
                    } catch {
                        result = error.localizedDescription
                    }
                    expect(result.count > 20).to(beTrue())
                }
            }
            
            context("when provided a tuple") {
                it("pass through") {
                    let tuple = (1, "1")
                    let res = try! TCJSONReflection.interpret(tuple) as! (Int, String)
                    expect(res.0).to(equal(tuple.0))
                    expect(res.1).to(equal(tuple.1))
                }
            }
            
            context("when provided an object") {
                let object = TestClass()
                
                it("should interpret the right amount of parameters") {
                    let object = TestClass()
                    let res = try! TCJSONReflection.interpret(object) as! [String: Any]
                    
                    expect(res.count).to(equal(10))
                }
                
                it("should interpret an object") {
                    let object = TestClass()
                    let res = try! TCJSONReflection.interpretObject(object)
                    let resObject = try! TestClass(fromDictionary: res)
                    expect(resObject).to(equal(object))
                }
                
                it("should throw if got an array") {
                    expect { try TCJSONReflection.interpretObject(["1", "2", "3"]) }
                        .to(throwError())
                }
                
                it("should throw if got a value") {
                    expect { try TCJSONReflection.interpretObject("1") }
                        .to(throwError())
                }
                
                it("should throw if got a optional") {
                    expect { try TCJSONReflection.interpretObject(Optional.some(object) as Any) }
                        .to(throwError())
                }
                
                it("should throw if got a dictionary") {
                    expect { try TCJSONReflection.interpretObject(["name": object]) }
                        .to(throwError())
                }
            }
            
            context("when provided an array") {
                let array: [Int] = [1, 2, 3]
                
                it("should throw if got an object") {
                    expect { try TCJSONReflection.interpretArray(TestClass()) }
                        .to(throwError())
                }
                
                it("should interpret an array") {
                    let res = try! TCJSONReflection.interpretArray(array)
                    let resArray = res as! Array<Int>
                    expect(resArray).to(equal(array))
                }
                
                it("should throw if got a value") {
                    expect { try TCJSONReflection.interpretArray("1") }
                        .to(throwError())
                }
                
                it("should throw if got a optional") {
                    expect { try TCJSONReflection.interpretArray(Optional.some(array) as Any) }
                        .to(throwError())
                }
                
                it("should throw if got a dictionary") {
                    expect { try TCJSONReflection.interpretArray(["name": array]) }
                        .to(throwError())
                }
            }
            
            context("when provided a complex object") {
                let extreme = TestClassWithExtemeCodingKeys()
                
                it("should interpret it correctly") {
                    let res = try! TCJSONReflection.interpretObject(extreme)
                    let result = try! TestClassWithExtemeCodingKeys.init(fromDictionary: res)
                    expect(result).to(equal(extreme))
                }
                
                it("should interpret correctly its system serialized version") {
                    let res = try! TCJSONReflection.systemSerialize(extreme)
                    let result = try! TestClassWithExtemeCodingKeys.init(fromDictionary: res as! [String: Any])
                    expect(result).to(equal(extreme))
                }
            }
            
            context("when provided a value") {
                let value: Int = 12345
                
                it("should interpret a value") {
                    let res = try! TCJSONReflection.interpret(value)
                    let resValue = res as! Int
                    expect(resValue).to(equal(value))
                }
            }
            
            context("when provided an optional") {
                let optional: Int? = 3
                
                it("should throw if got an object") {
                    expect { try TCJSONReflection.interpretOptional(TestClass()) }
                        .to(throwError())
                }
                
                it("should throw if got an array") {
                    expect { try TCJSONReflection.interpretOptional([1, 2, 3]) }
                        .to(throwError())
                }
                
                it("should throw if got a value") {
                    expect { try TCJSONReflection.interpretOptional("1") }
                        .to(throwError())
                }
                
                it("should interpret a optional") {
                    let res = try! TCJSONReflection.interpretOptional(optional as Any)
                    let resOptional = (res as Any?) as! Int?
                    
                    expect(resOptional ?? 0).to(equal(optional ?? 0))
                }
                
                it("should throw if got a dictionary") {
                    expect { try TCJSONReflection.interpretOptional(["name": optional]) }
                        .to(throwError())
                }
                
                it("should unwrap a double optional") {
                    let expected = 7
                    let doubleOpt: Any = Optional.some(Optional.some(expected)) as Any
                    let result = TCJSONReflection.unwrapOptional(doubleOpt)
                    
                    expect(TCJSONReflection.isOptional(result)).to(beFalse())
                    expect((result as! Int)).to(equal(expected))
                }
                
                it("should unwrap a normal optional") {
                    let result = TCJSONReflection.unwrapOptional(optional as Any)
                    
                    expect(TCJSONReflection.isOptional(result)).to(beFalse())
                    expect((result as! Int)).to(equal(optional!))
                }
                
                it("should do nothing to a nil value") {
                    let input = Optional<Any>.none as Any
                    
                    let result = TCJSONReflection.unwrapOptional(input)
                    let rMirror = { Mirror(reflecting: $0) }
                    
                    expect(TCJSONReflection.isOptional(
                        result,
                        mirror: rMirror))
                        .to(beTrue())
                    expect(TCJSONReflection.isNil(
                        result,
                        mirror: rMirror))
                        .to(beTrue())
                }
                
                it("should do nothing to a non optional value") {
                    let expected = 4
                    let result = TCJSONReflection.unwrapOptional(expected)
                    
                    expect(TCJSONReflection.isOptional(result)).to(beFalse())
                    expect((result as! Int)).to(equal(expected))
                }
            }
            
            context("when provided a dictionary") {
                let dict: [String: Int] = ["2": 2]
                
                it("should throw if got an object") {
                    expect { try TCJSONReflection.interpretDictionary(TestClass()) }
                        .to(throwError())
                }
                
                it("should throw if got an array") {
                    expect { try TCJSONReflection.interpretDictionary([1, 2, 3]) }
                        .to(throwError())
                }
                
                it("should throw if got a value") {
                    expect { try TCJSONReflection.interpretDictionary("1") }
                        .to(throwError())
                }
                
                it("should throw if got a optional") {
                    expect { try TCJSONReflection.interpretDictionary(
                        Optional.some(["name": dict]) as Any) }
                        .to(throwError())
                }
                
                it("should interpret a dictionary") {
                    let res = try! TCJSONReflection.interpretDictionary(dict as Any)
                    let resDict = res as! [String: Int]
                    
                    expect(resDict).to(equal(dict))
                }
            }
        }
    }
}
