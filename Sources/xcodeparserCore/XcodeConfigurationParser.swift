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
                let distance = remainder.distance(from: keyRange.lowerBound, to: keyRange.upperBound)
                currentIndex = configuration.index(currentIndex, offsetBy: distance)
                let remainderAfterKey = String(configuration[currentIndex..<configuration.endIndex])
                if let (value,valueRange) = remainderAfterKey.value() {
                    let distance = remainderAfterKey.distance(from: valueRange.lowerBound, to: valueRange.upperBound)
                    currentIndex = configuration.index(currentIndex, offsetBy: distance)
                    let e = XcodeSimpleExpression(value: value, comment: comment)
                    resultsDict[key] = e
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

