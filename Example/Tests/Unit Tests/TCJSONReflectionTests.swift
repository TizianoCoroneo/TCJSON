// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import TCJSON

class TCJSONReflectionSpec: QuickSpec {
  override func spec() {
    describe("TCJSONReflection") {
      
      context("checking optionals as Any") {
        
        it("can check if it is optional") {
          let result: Bool = Mirror.isOptional(
            Optional<Any>.some(
              "sss" as Any)
              as Any)
          
          expect(result).toEventually(beTrue())
        }
        
        it("can check if it is double optional") {
          let result = Mirror.isOptional(
            Optional<Any>.some(
              Optional<Any>.some(
                "sss" as Any)
                as Any)
              as Any)
          expect(result).to(beTrue())
        }
        
        it("can check if it is not optional") {
          let result = Mirror.isOptional(
            "sss" as Any)
          expect(result).to(beFalse())
        }
        
        it("can check if a nil is optional") {
          let result = Mirror.isOptional(
            Optional<Any>.none as Any)
          expect(result).to(beTrue())
        }
        
        it("can check if it is nil") {
          let result = Mirror.isNil(
            Optional<Any>.none as Any)
          expect(result).to(beTrue())
        }
        
        it("can check if it is double optional") {
          let result = Mirror.isNil(
            Optional<Any>.some(
              Optional<Any>.none as Any) as Any)
          expect(result).to(beFalse())
        }
        
        it("can check if it is not nil") {
          let result = Mirror.isNil(
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
          let res = try! Mirror.interpret(tuple) as! (Int, String)
          expect(res.0).to(equal(tuple.0))
          expect(res.1).to(equal(tuple.1))
        }
      }
      
      context("when provided an object") {
        let object = TestClass()
        
        it("should interpret the right amount of parameters") {
          let object = TestClass()
          let res = try! Mirror.interpret(object) as! [String: Any]
          
          expect(res.count).to(equal(10))
        }
        
        it("should interpret an object") {
          let object = TestClass()
          let res = try! Mirror.interpretObject(object)
          let resObject = try! TestClass(fromDictionary: res)
          expect(resObject).to(equal(object))
        }
        
        it("should throw if got an array") {
          expect { try Mirror.interpretObject(["1", "2", "3"]) }
            .to(throwError())
        }
        
        it("should throw if got a value") {
          expect { try Mirror.interpretObject("1") }
            .to(throwError())
        }
        
        it("should throw if got a optional") {
          expect { try Mirror.interpretObject(Optional.some(object) as Any) }
            .to(throwError())
        }
        
        it("should throw if got a dictionary") {
          expect { try Mirror.interpretObject(["name": object]) }
            .to(throwError())
        }
      }
      
      context("when provided an array") {
        let array: [Int] = [1, 2, 3]
        
        it("should throw if got an object") {
          expect { try Mirror.interpretArray(TestClass()) }
            .to(throwError())
        }
        
        it("should interpret an array") {
          let res = try! Mirror.interpretArray(array)
          let resArray = res as! Array<Int>
          expect(resArray).to(equal(array))
        }
        
        it("should throw if got a value") {
          expect { try Mirror.interpretArray("1") }
            .to(throwError())
        }
        
        it("should throw if got a optional") {
          expect { try Mirror.interpretArray(Optional.some(array) as Any) }
            .to(throwError())
        }
        
        it("should throw if got a dictionary") {
          expect { try Mirror.interpretArray(["name": array]) }
            .to(throwError())
        }
      }
      
      context("when provided a value") {
        let value: Int = 12345
        
        it("should interpret a value") {
          let res = try! Mirror.interpret(value)
          let resValue = res as! Int
          expect(resValue).to(equal(value))
        }
      }
      
      context("when provided an optional") {
        let optional: Int? = 3
        
        it("should throw if got an object") {
          expect { try Mirror.interpretOptional(TestClass()) }
            .to(throwError())
        }
        
        it("should throw if got an array") {
          expect { try Mirror.interpretOptional([1, 2, 3]) }
            .to(throwError())
        }
        
        it("should throw if got a value") {
          expect { try Mirror.interpretOptional("1") }
            .to(throwError())
        }
        
        it("should interpret a optional") {
          let res = try! Mirror.interpretOptional(optional as Any)
          let resOptional = (res as Any?) as! Int?
          
          expect(resOptional ?? 0).to(equal(optional ?? 0))
        }
        
        it("should throw if got a dictionary") {
          expect { try Mirror.interpretOptional(["name": optional]) }
            .to(throwError())
        }
        
        it("should unwrap a double optional") {
          let expected = 7
          let doubleOpt: Any = Optional.some(Optional.some(expected)) as Any
          let result = Mirror.unwrapOptional(doubleOpt)
          
          expect(Mirror.isOptional(result)).to(beFalse())
          expect((result as! Int)).to(equal(expected))
        }
        
        it("should unwrap a normal optional") {
          let result = Mirror.unwrapOptional(optional as Any)
          
          expect(Mirror.isOptional(result)).to(beFalse())
          expect((result as! Int)).to(equal(optional!))
        }
        
        it("should do nothing to a nil value") {
          let input = Optional<Any>.none as Any
          
          let result = Mirror.unwrapOptional(input)
          let rMirror = { Mirror(reflecting: $0) }
          
          expect(Mirror.isOptional(result, rMirror)).to(beTrue())
          expect(Mirror.isNil(result, rMirror)).to(beTrue())
        }
        
        it("should do nothing to a non optional value") {
          let expected = 4
          let result = Mirror.unwrapOptional(expected)
          
          expect(Mirror.isOptional(result)).to(beFalse())
          expect((result as! Int)).to(equal(expected))
        }
      }
      
      context("when provided a dictionary") {
        let dict: [String: Int] = ["2": 2]
        
        it("should throw if got an object") {
          expect { try Mirror.interpretDictionary(TestClass()) }
            .to(throwError())
        }
        
        it("should throw if got an array") {
          expect { try Mirror.interpretDictionary([1, 2, 3]) }
            .to(throwError())
        }
        
        it("should throw if got a value") {
          expect { try Mirror.interpretDictionary("1") }
            .to(throwError())
        }
        
        it("should throw if got a optional") {
          expect { try Mirror.interpretDictionary(
            Optional.some(["name": dict]) as Any) }
            .to(throwError())
        }
        
        it("should interpret a dictionary") {
          let res = try! Mirror.interpretDictionary(dict as Any)
          let resDict = res as! [String: Int]
          
          expect(resDict).to(equal(dict))
        }
      }
      
      context("when checking for CodingKey") {
        let obj = TestClassWithCodingKeys.init()
        let extremeObj = TestClassWithExtemeCodingKeys.init()
        let withoutKeys = TestClass.init()
        
        let result = try! Mirror.codingKeysLabels(inObject: obj)
        let extremeResult = try! Mirror.codingKeysLabels(inObject: extremeObj)
        
        it("doesn't change an object without CodingKeys") {
          let keys = try! Mirror.codingKeysLabels(inObject: withoutKeys)
          let equalValues = keys.map { $0.key == $0.value }.reduce(true) { $0 && $1 }
          let equalCount = keys.count == 10
          expect(equalValues && equalCount).to(beTrue())
        }
        
        it("returns the correct number of pairs") {
          expect(result.count).to(equal(11))
        }
        
        [
          ("string", true),
          ("emptyString", false),
          ("int3", true),
          ("int4", true),
          ("changedDouble", true),
          ("boolean3", true),
          ("boolean2", true),
          ("optional", true),
          ("nilOptional", true),
          ("array", true),
          ("object", true),
          ("dict", true)
          ].forEach {
            createTestCase(
              with: $0.0,
              contains: $0.1,
              withResult: result)
        }
        
//        [
//          ("string3", true),
//          ("string4", true),
//
//          ("int4", true),
//          ("int5", true),
//          ("int6", true),
//
//          ("double3", true),
//          ("double4", true),
//          ("double5", true),
//
//          ("boolean2", true),
//          ("boolean3", true),
//          ("boolean4", true),
//
//          ("optional4", true),
//          ("optional5", true),
//          ("optional6", true),
//
//          ("nilOptional4", true),
//          ("nilOptional5", true),
//          ("nilOptional6", true),
//
//          ("array4", true),
//          ("array5", true),
//          ("array6", true),
//
//          ("object4", true),
//          ("object5", true),
//          ("object6", true),
//
//          ("dict6", true),
//          ("dict7", true),
//          ("dict8", true),
//          ("dict9", true),
//          ("dict10", true),
//
//          ("disappear1", false),
//          ("disappear2", false),
//          ("disappear3", false),
//          ].forEach {
//            createTestCase(
//              with: $0.0,
//              contains: $0.1,
//              withResult: extremeResult)
//        }
        
        func createTestCase(
          with key: String,
          contains: Bool,
          withResult result: [String: String]) {
          it("extreme contains the \(key)") {
            let values = Array(result.values)
            if contains {
              expect(values).to(contain(key))
            } else {
              let shouldNotContainKey: ([String: String]) -> Bool = { !$0.keys.contains(key) }
              let valueShouldBeEmpty: ([String: String]) -> Bool = { $0[key]?.isEmpty ?? true }
              
              let success = shouldNotContainKey(result) || valueShouldBeEmpty(result)
              
              expect(success).to(beTrue())
            }
          }
        }
      }
    }
  }
}
