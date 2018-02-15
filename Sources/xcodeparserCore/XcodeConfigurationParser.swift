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
    public init(configuration : String) throws {
        guard let parsedConfiguration = try? ExpressionExtractor(with: configuration).parse()?.expression ?? "",!parsedConfiguration.isEmpty else {
            throw Result.invalid
        }
        self.configuration = String(parsedConfiguration.dropFirst().dropLast())
    }
    
    public func parse() throws  -> [String : XcodeExpression] {
        let resultsDict = try dictionary(from:self.configuration)
        return resultsDict
    }
}

private extension XcodeConfigurationParser {
    func dictionary(from string : String) throws  -> [String : XcodeExpression] {
        let queue = OperationQueue()
        let syncGroup = DispatchGroup()
        var resultsDict : [String : XcodeExpression] = [:]
        var currentIndex = string.startIndex
        while currentIndex < string.endIndex {
            let remainder = String(string[currentIndex..<string.endIndex])
            if let (_,commentRange) = remainder.comment() {
                currentIndex = string.index(index: currentIndex,after: commentRange)
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
                else if let firstChar = remainderAfterKey.first {
                    switch (firstChar) {
                    case "(":
                        if let expression = try? ExpressionExtractor(with: remainderAfterKey).parse(),let config = expression {
                            currentIndex = string.index(index: currentIndex,after: config.range)
                            syncGroup.enter()
                            queue.addOperation {
                                resultsDict[key] = .array(expression:XcodeListExpression(value:self.extractList(from: config.expression),comment:comment))
                                syncGroup.leave()
                            }
                        }
                        
                    case "{":
                        if let expression = try? ExpressionExtractor(with: remainderAfterKey).parse(),let config = expression {
                            currentIndex = string.index(index: currentIndex,after: config.range)
                            syncGroup.enter()
                            queue.addOperation {
                                let innerExpression = String(config.expression.dropFirst().dropLast())
                                if let expression  = try? self.dictionary(from: innerExpression) {
                                    resultsDict[key] = .dictionary(expression:XcodeDictionaryExpression(value: expression,comment:comment))
                                }
                                syncGroup.leave()
                            }
                            
                        }
                    default:
                        break
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
    
    func extractList(from string: String) -> [XcodeSimpleExpression] {
        var list : [XcodeSimpleExpression] = []
        var index = string.startIndex
        while let tuple = String(string[index..<string.endIndex]).listValue() {
            let expression = XcodeSimpleExpression(value: tuple.value, comment: tuple.comment)
            list += [expression]
            index = string.index(index: index,after: tuple.range)
        }
        return list
    }
}

