//
//  TCJSONReflectionCodingKeys.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 04/01/2018.
//

import Foundation

extension Mirror {
    
    public typealias Receiver = String
    public typealias Candidate = Receiver
    public typealias CandidatesDictionary = [Receiver: [Candidate]]
    public typealias BindingsDictionary = [Receiver: Candidate]
    
    static func assignLabel(
        fromList oldList: CandidatesDictionary,
        forReceiver receiver: Receiver)
        -> (assigned: BindingsDictionary, remaining: CandidatesDictionary) {
            
            func remove(
                assigned: BindingsDictionary,
                fromList list: CandidatesDictionary)
                -> (assigned: BindingsDictionary, remaining: CandidatesDictionary) {
                    let remaining = list.filter { !assigned.keys.contains($0.key) }
                    return (assigned: assigned, remaining: remaining)
            }
            
            let list = oldList.mapValues { cands in
                cands.filter { candidateHasUniqueReceiver($0, from: oldList) }
            }
            
            guard let candidates = list[receiver] else {
                let remaining = list.filter { $0.key != receiver }
                return (assigned: [:], remaining)
            }
            
            guard candidates.count != 0 else {
                return remove(
                    assigned: [receiver: receiver],
                    fromList: list)
            }
            
            guard candidates.count != 1 else {
                return remove(
                    assigned: [receiver: candidates.first!],
                    fromList: list)
            }
            
            let allPossibleReceivers = list
                .filter { $0.value == candidates }
                .map { $0.key }
            
            let result = Dictionary(
                uniqueKeysWithValues: zip(
                    allPossibleReceivers,
                    candidates))
            
            return remove(assigned: result, fromList: list)
    }
    
    static func getCandidates(
        forObject obj: [String: Any],
        comparingTo systemObj: [String: Any]) throws -> CandidatesDictionary {
        
        var result: CandidatesDictionary = obj.mapValues {
            (_: Any) -> [Candidate] in
            return [Candidate]()
        }

        try obj.forEach {
            result[$0.key] = try candidates(
                forChild: (label: $0.key, value: $0.value),
                inSystemInterpreted: systemObj)
        }
        
        return result
    }
    
    static func isUniqueBinding(
        _ receiver: Receiver,
        _ candidate: Candidate,
        inList list: CandidatesDictionary) -> Bool {
        
        return receiverHasUniqueCandidate(receiver, from: list)
        && candidateHasUniqueReceiver(candidate, from: list)
    }
    
    public static func codingKeysLabels<T: TCJSONCodable>(
        inObject object: T) throws -> BindingsDictionary {
        
        let tcInterpreted = try interpretObject(object)
        let systemInterpreted = try systemSerialize(object) as! [String: Any]
        
        guard !equals(systemInterpreted, tcInterpreted)
            else {
                return Dictionary(
                    uniqueKeysWithValues: zip(
                        tcInterpreted.keys,
                        tcInterpreted.keys))
        }
    
        let keysCandidatesDict = try getCandidates(
            forObject: tcInterpreted,
            comparingTo: systemInterpreted)

        let empty: BindingsDictionary = [:]
        
        let result: (BindingsDictionary, CandidatesDictionary?) = keysCandidatesDict.keys
            .reduce((empty, nil), {
                acc, originalKey in
                
                var (bindings, remainingCandidates) = acc

                let assigned = assignLabel(
                    fromList: remainingCandidates ?? keysCandidatesDict,
                    forReceiver: originalKey)
                
                assigned.assigned.forEach {
                    bindings[$0.key] = $0.value
                }

                return (bindings, assigned.remaining)
            })
        
        return result.0
    }
    
    //===========
    
    static func receivers(
        fromList list: CandidatesDictionary,
        forCandidate candidate: Candidate) -> [Receiver] {
        return list.flatMap({
            (receiver: Receiver, receiverCandidatesList: [Candidate]) -> Receiver? in
            return receiverCandidatesList.contains(candidate) ? receiver : nil
        })
    }
    
    static func receiverHasUniqueCandidate(
        _ receiver: Receiver,
        from candidateList: CandidatesDictionary)
        -> Bool {
            guard let candidates = candidateList[receiver] else { return false }
            return candidates.count == 1 //|| candidates.count == 0
    }
    
    static func candidateHasUniqueReceiver(
        _ candidate: Candidate,
        from candidateList: CandidatesDictionary)
        -> Bool {
            let result = receivers(
                fromList: candidateList,
                forCandidate: candidate)
            return result.count == 1 //|| result.count == 0
    }
    
    static func candidates(
        forChild child: Mirror.Child,
        inSystemInterpreted dict: [String: Any])
        throws -> [Candidate] {
            guard let label = child.label else { return [] }
            
            if dict.keys.contains(label) { return [label] }
            
            let sameValueCandidates = dict.filter {
                return equals(child.value, $0.value)
                }.map { $0.key }
            
            if sameValueCandidates.count != 0 {
                return sameValueCandidates
            }
            
            // A nil optional that wasn't decoded from the json
            // or a field excluded by CodingKey
            return Mirror.isNil(child.value) ? [label] : []
    }
    
    public static func systemSerialize<T: Encodable>(
        _ value: T) throws -> Any {
        let encoded: Data = try JSONEncoder()
            .encode(value)
        return try JSONSerialization
            .jsonObject(with: encoded)
            as! [String: Any]
    }
    
}
