// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import TCJSON

class TCJSONReflectionSpec: QuickSpec {
  override func spec() {
    describe("TCJSONReflection") {
      context("checking optionals as Any") {
        it("can check if it is optional") {
          let result = Mirror.isOptional(
            Optional<Any>.some(
              "sss" as Any)
              as Any)
          expect(result).to(beTrue())
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
        let result = try! Mirror.codingKeysLabels(inObject: obj)
        
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
              contains: $0.1)
        }
        
        func createTestCase(with key: String, contains: Bool) {
          it("contains the \(key)") {
            let values = Array(result.values)
            if contains {
              expect(values).to(contain(key))
            } else {
              expect(Array(result.keys)).toNot(contain(key))
            }
          }
        }
      }
    }
  }
}
