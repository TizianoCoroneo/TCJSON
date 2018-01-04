//
//  TCJSONReflectionCodingKeys.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 04/01/2018.
//

import Foundation

extension Mirror {
  
  public static func codingKeysLabels<T: TCJSONCodable>(
    inObject object: T) throws -> [String: String] {
    
    let newObjectData = try object.json.data()
    let jsonSerialize = try JSONSerialization.jsonObject(
      with: newObjectData)
    guard
      let serializedObject = jsonSerialize as? [String: Any] else { return [:] }
    
    let interpretedOldObject = try interpretObject(object)
    let interpretedNewObject = serializedObject
    
    guard !equals(interpretedNewObject, interpretedOldObject)
      else {
        return Dictionary(
          uniqueKeysWithValues: zip(
            interpretedOldObject.keys,
            interpretedOldObject.keys))
    }
    
    func candidates(
      forChild child: Mirror.Child)
      throws -> [String] {
        guard let label = child.label else { return [] }
        
        if try interpretedNewObject.first (where: {
          (new: (key: String, value: Any?)) throws -> Bool in
          label == new.key
        }) != nil { return [label] }
        
        let sameValueCandidates = try interpretedNewObject.filter {
          [child] (new: (key: String, value: Any)) throws -> Bool in
          return equals(child.value, new.value)
          }.map { $0.key }
        
        if sameValueCandidates.count == 0 {
          // A nil optional that wasn't decoded from the json
          if Mirror(reflecting: child.value)
            .displayStyle == .optional {
            return [label]
          }
          
          // or a field excluded by CodingKey
          return []
        } else {
          return sameValueCandidates
        }
    }
    
    let keysAndCandidatesPairs: [(String, [String])] = try interpretedOldObject.flatMap {
      (a: (key: String, value: Any)) -> (String, [String])? in
      let values = try candidates(forChild: (label: a.key, value: a.value))
      guard !values.isEmpty else { return nil }
      return (a.key, values)
      }.filter { !$0.1.isEmpty }
    
    let keysAndCandidates = Dictionary(uniqueKeysWithValues: keysAndCandidatesPairs)
    
    func assignLabel(
      fromList oldList: [String: [String]],
      forReceiver receiver: String)
      -> (assigned: [String: String], remaining: [String: [String]]) {
        
        func assigned(
          _ assigned: [String: String],
          fromList list: [String: [String]])
          -> (assigned: [String: String], remaining: [String: [String]]) {
            let remaining = list.filter { !assigned.keys.contains($0.key) }
            return (assigned: assigned, remaining: remaining)
        }
        
        let list = oldList.mapValues { cands in
          cands.filter { candidateHasSingleBinding($0, fromList: oldList) }
        }
        
        guard let candidates = list[receiver]?.filter ({ _ in true }) else {
          let remaining = list.filter { $0.key != receiver }
          return (assigned: [:], remaining)
        }

        guard candidates.count != 0 else {
          return assigned([receiver: receiver], fromList: list)
        }
        
        guard candidates.count != 1 else {
          return assigned([receiver: candidates.first!], fromList: list)
        }
        
        let allPossibleReceivers = list
          .filter { $0.value == candidates }
          .map { $0.key }

        let result = Dictionary(
          uniqueKeysWithValues: zip(
            allPossibleReceivers,
            candidates))
        
        return assigned(result, fromList: list)
    }
    
    func receivers(
      fromList list: [String: [String]],
      forCandidate cand: String) -> [String] {
      return list.flatMap({ (key: String, value: [String]) -> String? in
        return value.contains(cand) ? key : nil
      })
    }
    
    func receiverHasSingleBinding(
      _ receiver: String,
      fromList list: [String: [String]])
      -> Bool {
        guard let candidates = list[receiver] else { return false }
        return candidates.count == 1
    }
    
    func candidateHasSingleBinding(
      _ candidate: String,
      fromList list: [String: [String]])
      -> Bool {
        let recs = receivers(
          fromList: list,
          forCandidate: candidate)
        
        return recs.count == 1
    }
    
    func isUniqueBinding(
      _ receiver: String,
      inList list: [String: [String]]) -> Bool {

      let newList = list.mapValues { cands in
        cands.filter { candidateHasSingleBinding($0, fromList: list) }
      }
      
      return receiverHasSingleBinding(receiver, fromList: newList)
    }
    
    let empty: [String: String] = [:]
    
    let result: ([String: String], [String: [String]]?) = keysAndCandidates.keys
      .reduce((empty, nil), {
        acc, originalKey in
        
        let (accResults, accRemaining) = acc
        
        let assigned = assignLabel(
          fromList: accRemaining ?? keysAndCandidates,
          forReceiver: originalKey)
        
        let result = Dictionary(uniqueKeysWithValues: zip(
          Array(accResults.keys) + Array(assigned.assigned.keys),
          Array(accResults.values) + Array(assigned.assigned.values)))
        
        return (result, assigned.remaining)
      })
    
    return result.0
  }
}
