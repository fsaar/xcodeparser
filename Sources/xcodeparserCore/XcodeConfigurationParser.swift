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
    
    public func parse() throws  -> [String : Any] {
        let resultsDict = try dictionary(from:self.configuration)
        return resultsDict
    }
}

private extension XcodeConfigurationParser {
    func dictionary(from string : String) throws  -> [String : Any] {
        var resultsDict : [String : Any] = [:]
        var currentIndex = string.startIndex
        while currentIndex < string.endIndex {
            let remainder = String(string[currentIndex..<string.endIndex])
            if let (key,comment,keyRange) = remainder.keyValueStart() {
                currentIndex = string.index(index: currentIndex,after: keyRange)
                let remainderAfterKey = String(string[currentIndex..<string.endIndex])
                if let (value,valueRange) = remainderAfterKey.value() {
                    currentIndex = string.index(index: currentIndex,after: valueRange)
                    let e = XcodeSimpleExpression(value: value, comment: comment)
                    resultsDict[key] = e
                }
                else {
                    switch (string[currentIndex]) {
                    case "(":
                        if let expression = try? ExpressionExtractor(with: string).parse(),let config = expression {
                            currentIndex = string.index(index: currentIndex,after: config.range)
                            resultsDict[key] = XcodeListExpression(value:extractList(from: config.expression),comment:comment)
                        }
                        
                    case "{":
                        if let expression = try? ExpressionExtractor(with: string).parse(),let config = expression {
                            currentIndex = string.index(index: currentIndex,after: config.range)
                            let innerExpression = String(config.expression.dropFirst().dropLast())
                            resultsDict[key] = XcodeDictionaryExpression(value: try dictionary(from: innerExpression),comment:comment)
                        }
                    default:
                        break
                    }
                    currentIndex = string.index(after: currentIndex)
                }
            }
            else
            {
                currentIndex = string.index(after: currentIndex)
            }
        }
        
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

