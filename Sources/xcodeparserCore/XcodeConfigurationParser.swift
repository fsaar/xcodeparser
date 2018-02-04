//
//  CommandLineParser.swift
//  filesizePackageDescription
//
//  Created by Frank Saar on 21/12/2017.
//

import Foundation


public struct XcodeSimpleExpression {
    public let value : String
    public let comment : String?
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
    
    public func parse(using dict : [String:Any] = [:]) throws  -> [String : Any] {
        var resultsDict = dict
        var currentIndex = configuration.startIndex
        while currentIndex < configuration.endIndex {
            let remainder = String(configuration[currentIndex..<configuration.endIndex])
            if let (key,comment,keyRange) = remainder.keyValueStart() {
                currentIndex = configuration.index(index: currentIndex,after: keyRange)
                let remainderAfterKey = String(configuration[currentIndex..<configuration.endIndex])
                if let (value,valueRange) = remainderAfterKey.value() {
                    currentIndex = configuration.index(index: currentIndex,after: valueRange)
                    let e = XcodeSimpleExpression(value: value, comment: comment)
                    resultsDict[key] = e
                }
                else {
                    switch (configuration[currentIndex]) {
                    case "{":
                        if let config = try? ExpressionExtractor(with: configuration).parse() {
                            
                        }
                        break
                    case "(":
                        break
                    default:
                        break
                    }
                    currentIndex = configuration.index(after: currentIndex)
                }
            }
            else
            {
                currentIndex = configuration.index(after: currentIndex)
            }
        }
    
        return resultsDict
    }
}
//

