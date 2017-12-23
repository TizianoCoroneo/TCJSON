// https://github.com/Quick/Quick

import Quick
import Nimble
import TCJSON

fileprivate struct TestClass: TCJSONCodable, Equatable {
    var string: String = "aaa"
    var int: Int = 10
    var optional: String? = "bbb"
    
    static func ==(_ a: TestClass, _ b: TestClass) -> Bool {
        return a.string == b.string
        && a.int == b.int
        && a.optional == b.optional
    }
}

class TCJSONSpec: QuickSpec {
    override func spec() {
        describe("TCJSONCodable") {
            context("when provided with content") {
                var instance: TestClass! = nil
                beforeEach {
                    instance = TestClass.init()
                }
                
                it("can convert in JSON data") {
                    expect(expression: instance.json.data)
                        .toNot(throwError())
                }
                
                it("Can directly return content") {
                    expect(expression: instance.json.content)
                        .to(equal(instance))
                }
                
                it("can retrieve from data") {
                    let data = try! instance.json.data()
                    expect {
                        return try TestClass
                        .init(fromData: data)
                    }.notTo(throwError())
                }
            }
            
            context("when provided with data") {
                var instance: TestClass! = nil
                var data: Data! = nil
                
                beforeEach {
                    instance = TestClass.init()
                    data = try! instance.json.data()
                }
                
                it("can retrieve correct content") {
                    let res = try! TestClass.init(fromData: data)
                    expect(res.string).to(equal(instance.string))
                    expect(res.int).to(equal(instance.int))
                    expect(res.optional).to(equal(instance.optional))
                }
                
                it("can directly return data") {
                    let new = TCJSON<TestClass>.init(data)
                    expect(expression: new.data)
                        .to(equal(data))
                }
            }
            
            context("when provided with a JSON formatted string") {
                let string = """
{
"string": "test",
"int": 11,
"optional": null
}
"""
                it("can parse it into an object") {
                    expect { try TestClass.init(fromJSONString: string) }
                    .notTo(throwError())
                }
                
                it("can retrieve the correct values") {
                    let res = try! TestClass.init(fromJSONString: string)
                    expect(res.string).to(equal("test"))
                    expect(res.int).to(equal(11))
                    expect(res.optional).to(beNil())
                }
            }
            
            context("when provided with a dictionary") {
                let dict: [String: Any] = [
                    "string": "ccc",
                    "int": 20,
                    "optional": "ddd"
                ]
                
                it("can initialize the model") {
                    expect { return try TestClass(fromDictionary: dict) }
                        .notTo(throwError())
                }
                
                it("can retrieve the correct data") {
                    let res = try! TestClass(fromDictionary: dict)
                    
                    let expected = TestClass.init(
                        string: "ccc",
                        int: 20,
                        optional: "ddd")
                    
                    expect(res).to(equal(expected))
                }
            }

            context("should throw an error") {
                
                let data: Data = {
                    let string = "asjdlakdja"
                    return string.data(using: .utf8)!
                }()
                
                let string = "🤢"
                
                let dict: [String: Any?] = [
                    "string": "",
                    "int": nil,
                    "optional": 10
                ]
                
                it("when provided invalid data") {
                    expect {
                        return try TestClass(fromData: data)
                        } .to(throwError())
                }
                
                it("when provided invalid json string") {
                    expect {
                        return try TestClass(fromJSONString: string)
                        } .to(throwError())
                }
                
                it("when provided with a invalid dictionary") {
                    expect { return try TestClass(fromDictionary: dict) }
                        .to(throwError())
                }
            }

            
            context("when provided with closures") {
                var instance: TestClass! = nil
                
                beforeEach {
                    instance = TestClass()
                }
                
                it("can map over content") {
                    let res = try! instance.json.map(content: {
                        return $0.string + " aaa"
                    })
                    
                    expect(expression: res.content).to(equal("aaa aaa"))
                }
                
                it("can map over data") {
                    let res = try! instance.json.map(data: {
                        return try! TestClass.init(fromData: $0).string
                    })
                    
                    expect(expression: res.content).to(equal("aaa"))
                }
                
                it("can flatMap over content") {
                    let expected = TestClass.init(
                        string: "aaa",
                        int: 11,
                        optional: "bbb")
                    
                    let res = try! instance.json.flatMap(content: {
                        return TCJSON.init(
                            TestClass.init(
                            string: $0.string,
                            int: $0.int + 1,
                            optional: $0.optional))
                    })
                    
                    expect(expression: res.content).to(equal(expected))
                }
                
                it("can flatMap over data") {
                    let res = try! instance.json.flatMap(data: {
                        return TCJSON<TestClass>.init($0)
                    })
                    
                    expect(expression: res.content).to(equal(instance))
                }
                
                it("can flatten single TCJSONs") {
                    let json = TCJSON.init(instance)
                    expect(expression: { try json.flatten().content() })
                        .to(equal(instance))
                }
                
                it("can flatten double TCJSONs") {
                    let json = TCJSON.init(TCJSON.init(instance))
                    expect(expression: { try json.flatten().content() })
                        .to(equal(instance))
                }
                
                it("can apply a function over content") {
                    var result: String? = nil
                    try! instance.json.apply(content: {
                        result = $0.string
                    })
                    
                    expect(result).to(equal("aaa"))
                }
                
                it("can apply a function over data") {
                    var result: String? = nil
                    try! instance.json.apply(data: {
                        result = try! TCJSON<TestClass>($0).content().string
                    })
                    
                    expect(result).to(equal(instance.string))
                }
                
                it("can zip over content") {
                    var instance2 = TestClass()
                    instance2.int = 1
                    let res = try! TCJSON<Int>.zip(
                        x: instance.json,
                        y: instance2.json,
                        closure: { (a: TestClass, b: TestClass) -> Int in
                            return a.int + b.int
                    })
                    
                    expect(expression: res.content).to(equal(11))
                }
            }
        }
    }
}
