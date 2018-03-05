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

    let queue = { ()-> OperationQueue in
        let q =  OperationQueue()
        q.qualityOfService = .userInitiated
        return q
    }()

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
        let resultsDict = try dictionary(from:configuration[innerRange],with:innerRange)
        return resultsDict
    }
}

private extension XcodeConfigurationParser {
    func dictionary(from string : Substring,with range : ClosedRange<String.Index>) throws  -> [String : XcodeExpression] {
        let syncGroup = DispatchGroup()
        var resultsDict : [String : XcodeExpression] = [:]
        var currentIndex = range.lowerBound
        while currentIndex <= range.upperBound {
            let remainder = string[currentIndex...range.upperBound]
            if let (_,commentRange) = String(remainder).commentWithWhiteSpaceAndNewLines() {
                currentIndex = string.index(index: currentIndex,after: commentRange)
                continue
            }
            
            if let (key,comment,keyRange) = String(string[currentIndex...range.upperBound]).keyValueStart() {
                currentIndex = string.index(index: currentIndex,after: keyRange)
                let remainderAfterKey = String(string[currentIndex...range.upperBound])
                if let (value,valueRange) = remainderAfterKey.value() {
                    currentIndex = string.index(index: currentIndex,after: valueRange)
                    let e = XcodeSimpleExpression(value: value, comment: comment)
                    resultsDict[key] = .assignment(expression: e)
                }
                else if let expressionRange = rangeDict[currentIndex],let firstChar = remainderAfterKey.first  {
                    let innerRange = string.innerRange(of: expressionRange)
                    let expression = string[innerRange]
                    currentIndex = string.index(after:expressionRange.upperBound)
                    if string[currentIndex] == ";" {
                        currentIndex = string.index(after: currentIndex)
                    }
                    syncGroup.enter()
                    queue.addOperation {
                        switch (firstChar) {
                        case "(":
                            resultsDict[key] = .array(expression:XcodeListExpression(value:self.extractList(from: expression,with:innerRange),comment:comment))
                        case "{":
                            if let dictionary  = try? self.dictionary(from: expression,with: innerRange) {
                                resultsDict[key] = .dictionary(expression:XcodeDictionaryExpression(value: dictionary,comment:comment))
                            }
                        default:
                            break
                        }
                        syncGroup.leave()
                    }
                }
            }
            else
            {
                let upperBound = string.index(after:range.upperBound)
                currentIndex = string.index(currentIndex, offsetBy: 1, limitedBy: upperBound) ?? upperBound
            }
        }
        syncGroup.wait()
        return resultsDict
    }
    
    func extractList(from string: Substring,with range : ClosedRange<String.Index>) -> [XcodeSimpleExpression] {
        var list : [XcodeSimpleExpression] = []
        var index = range.lowerBound
        while index<=range.upperBound,let tuple = String(string[index...range.upperBound]).listValue() {
            let expression = XcodeSimpleExpression(value: tuple.value, comment: tuple.comment)
            list += [expression]
            index = string.index(index: index,after: tuple.range)
        }
        return list
    }
}

