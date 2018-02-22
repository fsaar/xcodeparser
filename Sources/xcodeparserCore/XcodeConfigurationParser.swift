//
//  XcodeConfigurationParser.swift
//
//  Created by Frank Saar on 29/01/2018.
//

import Foundation

public class XcodeConfigurationParser {
    
    public enum Result : Error {
        case invalid
    }
    
    let configuration : String
    let rangeDict : [String.Index:ClosedRange<String.Index>]
    public init(configuration : String) throws {
        guard let dict = try? ExpressionExtractor(with: configuration).parse() ,!dict.keys.isEmpty else {
            throw Result.invalid
        }
        self.configuration = configuration
    
        rangeDict = dict
    }
    
    public func parse() throws  -> [String : XcodeExpression] {
        let range = rangeDict.values.sorted(by: { $0.lowerBound < $1.lowerBound })[0]
        let innerRange = configuration[range].innerRange(of: range)
        let resultsDict = try dictionary(from:configuration[innerRange],with:innerRange.lowerBound)
        return resultsDict
    }
}

private extension XcodeConfigurationParser {
    func dictionary(from string : Substring,with startIndex : String.Index) throws  -> [String : XcodeExpression] {
        let queue = OperationQueue()
        let syncGroup = DispatchGroup()
        var resultsDict : [String : XcodeExpression] = [:]
        var currentIndex = startIndex
        while currentIndex < string.endIndex {
            let remainder = string[currentIndex..<string.endIndex]
            if let (_,commentRange) = String(remainder).comment() {
                currentIndex = string.index(index: currentIndex,after: commentRange)
                continue
            }
            
            if let (key,comment,keyRange) = String(string[currentIndex..<string.endIndex]).keyValueStart() {
                currentIndex = string.index(index: currentIndex,after: keyRange)
                let remainderAfterKey = String(string[currentIndex..<string.endIndex])
                if let (value,valueRange) = remainderAfterKey.value() {
                    currentIndex = string.index(index: currentIndex,after: valueRange)
                    syncGroup.enter()
                    queue.addOperation {
                        let e = XcodeSimpleExpression(value: value, comment: comment)
                        resultsDict[key] = .assignment(expression: e)
                        syncGroup.leave()
                    }
                }
                else if let range = rangeDict[currentIndex],let firstChar = remainderAfterKey.first  {
                    let innerRange = string.innerRange(of: range)
                    let expression = string[innerRange]
                    currentIndex = string.index(after:range.upperBound)
                    syncGroup.enter()
                    queue.addOperation {
                        switch (firstChar) {
                        case "(":
                            resultsDict[key] = .array(expression:XcodeListExpression(value:self.extractList(from: expression,with:innerRange.lowerBound),comment:comment))
                        case "{":
                            if let dictionary  = try? self.dictionary(from: expression,with: innerRange.lowerBound) {
                                resultsDict[key] = .dictionary(expression:XcodeDictionaryExpression(value: dictionary,comment:comment))
                            }
                        default:
                            break
                        }
                        syncGroup.leave()
                    }
                    currentIndex =  string.index(currentIndex, offsetBy: 1, limitedBy: string.endIndex) ?? string.endIndex
                }
            }
            else
            {
                currentIndex = string.index(currentIndex, offsetBy: 1, limitedBy: string.endIndex) ?? string.endIndex
            }
        }
        syncGroup.wait()
        return resultsDict
    }
    
    func extractList(from string: Substring,with startIndex : String.Index) -> [XcodeSimpleExpression] {
        var list : [XcodeSimpleExpression] = []
        var index = startIndex
        while let tuple = String(string[index..<string.endIndex]).listValue() {
            let expression = XcodeSimpleExpression(value: tuple.value, comment: tuple.comment)
            list += [expression]
            index = string.index(index: index,after: tuple.range)
        }
        return list
    }
}

