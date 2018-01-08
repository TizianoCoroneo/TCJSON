//
//  TCJSONReflectionCodingKeys.swift
//  TCJSON
//
//  Created by Tiziano Coroneo on 04/01/2018.
//

import Foundation

extension TCJSONReflection {
    
    public typealias Receiver = String
    public typealias Candidate = Receiver
    public typealias CandidatesDictionary = [Receiver: [Candidate]]
    public typealias BindingsDictionary = [Receiver: Candidate]
    
    static func applyMultiLevelCodingKeys<T: TCJSONCodable>(
        toObject obj: T) throws -> [String: Any] {
        
        let dict = try obj.json.dictionary()
        let codingKeys = try TCJSONReflection.codingKeysLabels(inObject: obj)
        
        guard obj.codingKeysForNestedObject.count != 0 else {
            return try applySingleLevelCodingKey(dict, codingKeys: codingKeys)
        }
        
        let newKeyValuePairs = try dict.map {
            (pair: (key: String, value: Any)) -> (String, Any) in
            
            guard
                let value = pair.value as? [String: Any],
                let codingKeys = obj.codingKeysForNestedObject[pair.key]
                else { return pair }
            
            let newVal = try applySingleLevelCodingKey(value, codingKeys: codingKeys)
            return (pair.key, newVal)
        }
        
        return Dictionary(uniqueKeysWithValues: newKeyValuePairs)
    }
    
    static func applySingleLevelCodingKey(
        _ dict: [String: Any],
        codingKeys: [String: String])
        throws -> [String: Any] {
            let newKeys: [(String, Any)] = dict.map {
                (pair) -> (key: String, value: Any) in
                return (
                    key: codingKeys[pair.key] ?? pair.key,
                    value: pair.value)
            }
            
            return Dictionary<String, Any>(
                newKeys, uniquingKeysWith: { a, _ in a })
    }
    
    /// Describes the content of the coding keys of a class by comparing a system interpreted object and a naively interpreted one.
    ///
    /// - Parameter object: Request object
    /// - Returns: A dictionary where the keys are the name of the old property and the values are the new names from the coding key.
    /// - Throws: Rethrows from the system interpreting of the object and from the naive interpreting.
    public static func codingKeysLabels<T: Codable>(
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
        
        let keysCandidatesDict: [String: [String]] = getCandidates(
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
    
    /// Assigns a new candidate name to a receiver by reading from the sourceList.
    ///
    /// - Parameters:
    ///   - oldList: The source list
    ///   - receiver: The receiver to apply the candidate name to.
    /// - Returns: A tuple where the first element is a binding dictionary like `["oldName": "newName"]`; and the second value is the `oldList` minus the newly assigned label.
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
            
            if receiverHasUniqueCandidate(receiver, from: oldList) {
                return remove(
                    assigned: [receiver: oldList[receiver]!.first!],
                    fromList: oldList)
            }
            
            guard let candidates = oldList[receiver] else {
                let remaining = oldList.filter { $0.key != receiver }
                return (assigned: [:], remaining)
            }
            
            guard candidates.count != 0 else {
                return remove(
                    assigned: [receiver: receiver],
                    fromList: oldList)
            }
            
            guard candidates.count != 1 else {
                return remove(
                    assigned: [receiver: candidates.first!],
                    fromList: oldList)
            }
            
            let allPossibleReceivers = oldList
                .filter { $0.value == candidates }
                .map { $0.key }
            
            let result = Dictionary(
                uniqueKeysWithValues: zip(
                    allPossibleReceivers,
                    candidates))
            
            return remove(assigned: result, fromList: oldList)
    }
    
    /// Returns the receiver:candidates dictionary by comparing two different dictionaries.
    ///
    /// - Parameters:
    ///   - obj: The object as interpreted by tcjson.
    ///   - systemObj: The object as interpreted by the system.
    /// - Returns: The candidates dictionary.
    static func getCandidates(
        forObject obj: [String: Any],
        comparingTo systemObj: [String: Any]) -> CandidatesDictionary {
        
        var result: CandidatesDictionary = obj.mapValues {
            (_: Any) -> [Candidate] in
            return [Candidate]()
        }
        
        obj.forEach {
            result[$0.key] = candidates(
                forChild: (label: $0.key, value: $0.value),
                inSystemInterpreted: systemObj)
        }
        
        return result
    }
    
    
    /// Checks if the binding between a receiver and a candidate is unique.
    ///
    /// - Parameters:
    ///   - receiver: The receiver that will get the candidate name.
    ///   - candidate: The candidate name for the receiver.
    ///   - list: The source list.
    /// - Returns: True if the binding is unique.
    static func isUniqueBinding(
        _ receiver: Receiver,
        _ candidate: Candidate,
        inList list: CandidatesDictionary) -> Bool {
        
        return receiverHasUniqueCandidate(receiver, from: list)
            && candidateHasUniqueReceiver(candidate, from: list)
    }
    
    /// Checks if the provided receiver has only one possible candidate.
    ///
    /// - Parameters:
    ///   - receiver: The receiver to check.
    ///   - candidateList: The source list.
    /// - Returns: true if the receiver has a unique candidate.
    static func receiverHasUniqueCandidate(
        _ receiver: Receiver,
        from candidateList: CandidatesDictionary)
        -> Bool {
            guard let candidates = candidateList[receiver] else { return false }
            return candidates.count == 1
    }
    
    /// Checks if the provided candidate has only one possible receiver.
    ///
    /// - Parameters:
    ///   - candidate: The candidate to check
    ///   - candidateList: The source list.
    /// - Returns: true if the candidate has a unique receiver.
    static func candidateHasUniqueReceiver(
        _ candidate: Candidate,
        from candidateList: CandidatesDictionary)
        -> Bool {
            let result = receivers(
                fromList: candidateList,
                forCandidate: candidate)
            return result.count == 1
    }
    
    /// All the possible receivers for the given candidate.
    ///
    /// - Parameters:
    ///   - list: The source list.
    ///   - candidate: The candidate to check
    /// - Returns: All the possible receivers.
    static func receivers(
        fromList list: CandidatesDictionary,
        forCandidate candidate: Candidate) -> [Receiver] {
        return list.flatMap({
            (receiver: Receiver, receiverCandidatesList: [Candidate]) -> Receiver? in
            return receiverCandidatesList.contains(candidate) ? receiver : nil
        })
    }
    
    /// Finds all the candidates for a receiver in a system interpreted object.
    ///
    /// - Parameters:
    ///   - child: Mirror child with to which assign the new codingkey.
    ///   - dict: The system interpreted dictionary.
    /// - Returns: All the found candidates
    static func candidates(
        forChild child: Mirror.Child,
        inSystemInterpreted dict: [String: Any])
        -> [Candidate]? {
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
            return isNil(child.value) ? nil : []
    }
    
    /// Use the system serializer to create a JSON Any instance.
    ///
    /// - Parameter value: the encodable object to use.
    /// - Returns: the object encoded as dictionary, as Any.
    /// - Throws: Rethrows from the JSONEncoder.encode method.
    public static func systemSerialize<T: Encodable>(
        _ value: T) throws -> Any {
        let encoded: Data = try JSONEncoder()
            .encode(value)
        return try JSONSerialization
            .jsonObject(with: encoded)
            as! [String: Any]
    }
}
