// https://github.com/Quick/Quick

import Quick
import Nimble
import TCJSON

class TCJSONSpec: QuickSpec {
    static let exampleJSONString = """
{
"string": "ccc",
"int": 11,
"double": 11.2,
"boolean": false,
"optional": "ddd",
"nilOptional": null,
"array": ["ccc", "ddd"],
"object": { "name": "eee" },
"dict": { "1": 1 }
}
"""
    
    static let expectedFromJSONString: TestClass = TestClass(
        string: "ccc",
        int: 11,
        double: 11.2,
        boolean: false,
        optional: "ddd",
        nilOptional: nil,
        array: ["ccc", "ddd"],
        object: TestClass.Object.init(name: "eee"),
        dict: ["1": 1])
    
    static let exampleDictionary: [String: Any?] = [
        "string": "ccc",
        "int": 11,
        "double": 11.2,
        "boolean": false,
        "optional": "ddd",
        "nilOptional": nil,
        "array": ["ccc", "ddd"],
        "object": ["name": "eee"],
        "dict": ["1": 1]
    ]
    
    static let expectedFromDictionary: TestClass = TestClass(
        string: "ccc",
        int: 11,
        double: 11.2,
        boolean: false,
        optional: "ddd",
        nilOptional: nil,
        array: ["ccc", "ddd"],
        object: TestClass.Object(name: "eee"),
        dict: ["1": 1])
    
    
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
                
                it("can retrieve a dictionary") {
                    let dict = try! instance.json.dictionary()
                    expect {
                        return TestClass.init(
                            string: dict["string"] as! String,
                            int: dict["int"] as! Int,
                            double: dict["double"] as! Double,
                            boolean: dict["boolean"] as! Bool,
                            optional: dict["optional"] as? String,
                            nilOptional: dict["nilOptional"]  as? String,
                            array: dict["array"] as! [String],
                            object: try! TestClass.Object(fromJSON: dict["object"]!),
                            dict: ["1": 1])
                        }.to(equal(instance))
                }
            }
            
            context("when provided with data") {
                var expectedFromData: TestClass! = nil
                var data: Data! = nil
                
                beforeEach {
                    expectedFromData = TestClass.init()
                    data = try! expectedFromData.json.data()
                }
                
                it("can retrieve correct content") {
                    let res = try! TestClass(fromData: data)
                    expect(res).to(equal(expectedFromData))
                }
                
                it("can directly return data") {
                    let new = TCJSON<TestClass>(data)
                    expect(expression: new.data)
                        .to(equal(data))
                }
                
                it("can retrieve a dictionary") {
                    let res = try! TestClass(fromData: data)
                    let dict = try! TestClass(fromDictionary: try! res.json.dictionary())
                    expect (dict).to(equal(expectedFromData))
                }
            }
            
            context("when provided with a JSON formatted string") {
                it("can parse it into an object") {
                    expect { try TestClass(fromJSONString: TCJSONSpec.exampleJSONString) }
                        .notTo(throwError())
                }
                
                it("can retrieve the correct values") {
                    let res = try! TestClass(fromJSONString: TCJSONSpec.exampleJSONString)
                    expect(res).to(equal(TCJSONSpec.expectedFromJSONString))
                }
                
                it("can retrieve a dictionary") {
                    let res = try! TestClass(fromJSONString: TCJSONSpec.exampleJSONString)
                    let dict = try! TestClass(fromDictionary: try! res.json.dictionary())
                    expect (dict).to(equal(TCJSONSpec.expectedFromJSONString))
                }
            }
            
            context("when provided with a dictionary") {
                
                it("can initialize the model") {
                    expect { return try TestClass(fromDictionary: TCJSONSpec.exampleDictionary) }
                        .notTo(throwError())
                }
                
                it("can retrieve the correct data") {
                    let res = try! TestClass(fromDictionary: TCJSONSpec.exampleDictionary)
                    expect(res).to(equal(TCJSONSpec.expectedFromDictionary))
                }
                
                it("can retrieve a dictionary") {
                    let res = try! TestClass(fromDictionary: TCJSONSpec.exampleDictionary)
                    let dict = try! TestClass(fromDictionary: try! res.json.dictionary())
                    expect(dict).to(equal(TCJSONSpec.expectedFromDictionary))
                }
            }
            
            context("should throw an error") {
                
                let wrongData: Data = {
                    let string = "asjdlakdja"
                    return string.data(using: .utf8)!
                }()
                
                let wrongString = "🤢"
                
                let wrongDict: [String: Any?] = [
                    "string": "",
                    "int": nil,
                    "optional": 10
                ]
                
                it("when provided invalid data") {
                    expect {
                        return try TestClass(fromData: wrongData)
                        } .to(throwError())
                }
                
                it("when provided invalid json string") {
                    expect {
                        return try TestClass(fromJSONString: wrongString)
                        } .to(throwError())
                }
                
                it("when provided with a invalid dictionary") {
                    expect { return try TestClass(fromDictionary: wrongDict) }
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
                        return try! TestClass(fromData: $0).string
                    })
                    
                    expect(expression: res.content).to(equal("aaa"))
                }
                
                it("can flatMap over content") {
                    let expected = TestClass(
                        string: "aaaa",
                        int: 11,
                        double: 11.2,
                        boolean: false,
                        optional: nil,
                        nilOptional: "bbb",
                        array: ["aaa", "bbb", "ccc"],
                        object: TestClass.Object(name: "aaa"),
                        dict: ["1": 1])
                    
                    let res = try! instance.json.flatMap(content: {
                        return TCJSON( TestClass(
                            string: $0.string + "a",
                            int: $0.int + 1,
                            double: $0.double + 1,
                            boolean: false,
                            optional: $0.nilOptional,
                            nilOptional: $0.optional,
                            array: $0.array + ["ccc"],
                            object: TestClass.Object(name: "aaa"),
                            dict: ["1": 1]))
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
