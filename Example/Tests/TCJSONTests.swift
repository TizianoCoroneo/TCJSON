// https://github.com/Quick/Quick

import Quick
import Nimble
import TCJSON

struct TestClass: TCJSONCodable, Equatable {
    var string: String = "aaa"
    var int: Int = 10
    var double: Double = 10.2
    var boolean: Bool = true
    var optional: String? = "bbb"
    var nilOptional: String? = nil
    var array: [String] = ["aaa", "bbb"]
    var object: Object? = Object(name: "ccc")
    var dict: [String: Int] = ["1": 1]
    
    struct Object: TCJSONCodable {
        let name: String
        
        static func ==(lhs: TestClass.Object, rhs: TestClass.Object) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    static func ==(_ a: TestClass, _ b: TestClass) -> Bool {
        return a.string == b.string
            && a.int == b.int
            && a.double == b.double
            && a.boolean == b.boolean
            && a.optional == b.optional
            && a.nilOptional == b.nilOptional
            && a.array == b.array
            && a.object.equals(b.object)
    }
}

extension Optional where Wrapped == TestClass.Object {
    func equals(_ other: TestClass.Object?) -> Bool {
        switch self {
        case nil:
            return other == nil
        case let value:
            guard let other = other else { return false }
            return other == value!
        }
    }
}

class TCJSONSpec: QuickSpec {
    override func spec() {
       
        let exampleJSONString = """
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
        
        let expectedFromJSONString = TestClass(
            string: "ccc",
            int: 11,
            double: 11.2,
            boolean: false,
            optional: "ddd",
            nilOptional: nil,
            array: ["ccc", "ddd"],
            object: TestClass.Object.init(name: "eee"),
            dict: ["1": 1])
        
        let exampleDictionary: [String: Any?] = [
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
        
        let expectedFromDictionary = TestClass(
            string: "ccc",
            int: 11,
            double: 11.2,
            boolean: false,
            optional: "ddd",
            nilOptional: nil,
            array: ["ccc", "ddd"],
            object: TestClass.Object(name: "eee"),
            dict: ["1": 1])
        
        
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
                    expect { try TestClass(fromJSONString: exampleJSONString) }
                    .notTo(throwError())
                }
                
                it("can retrieve the correct values") {
                    let res = try! TestClass(fromJSONString: exampleJSONString)
                    expect(res).to(equal(expectedFromJSONString))
                }
                
                it("can retrieve a dictionary") {
                    let res = try! TestClass(fromJSONString: exampleJSONString)
                    let dict = try! TestClass(fromDictionary: try! res.json.dictionary())
                    expect (dict).to(equal(expectedFromJSONString))
                }
            }
            
            context("when provided with a dictionary") {
                
                it("can initialize the model") {
                    expect { return try TestClass(fromDictionary: exampleDictionary) }
                        .notTo(throwError())
                }
                
                it("can retrieve the correct data") {
                    let res = try! TestClass(fromDictionary: exampleDictionary)
                    expect(res).to(equal(expectedFromDictionary))
                }
                
                it("can retrieve a dictionary") {
                    let res = try! TestClass(fromDictionary: exampleDictionary)
                    let dict = try! TestClass(fromDictionary: try! res.json.dictionary())
                    expect(dict).to(equal(expectedFromDictionary))
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
