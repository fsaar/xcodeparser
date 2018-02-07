//
//  XcodeConfigurationParser.swift
//
//  Created by Frank Saar on 29/01/2018.
//

import Foundation


public struct XcodeSimpleExpression : Equatable {
    public let value : String
    public let comment : String?
    public init (value: String,comment: String? = nil) {
        self.value = value
        self.comment = comment
    }
    static public func ==(lhs : XcodeSimpleExpression,rhs : XcodeSimpleExpression) -> Bool {
        return lhs.value == rhs.value && lhs.comment == rhs.comment
    }
}


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
                            resultsDict[key] = extractList(from: config.expression)
                        }
                        
                    case "{":
                        if let expression = try? ExpressionExtractor(with: string).parse(),let config = expression {
                            currentIndex = string.index(index: currentIndex,after: config.range)
                            resultsDict[key] = try dictionary(from: config.expression)
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

