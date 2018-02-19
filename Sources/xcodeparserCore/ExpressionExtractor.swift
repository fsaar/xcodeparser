//
//  XcodeExpressionExtractor.swift
//
//  Created by Frank Saar on 29/01/2018.
//

import Foundation


public class ExpressionExtractor {
    private enum State {
        case searching
        case started(String.Index)
        case end
    }
    public enum ErrorType : Error {
        case invalidSyntax
    }
    private var state = State.searching
    public let content : String
    private let tupleSet = Set([ExpressionStackPair(open: "{", close: "}"),ExpressionStackPair(open: "(", close: ")")])
    
    public  init(with content : String) {
        self.content = content
    }
    
    public func parse() throws -> [String.Index:ClosedRange<String.Index>] {
        var rangeDict : [String.Index:ClosedRange<String.Index>] = [:]
        let stack = ExpressionStack(pairs: self.tupleSet)
        var currentIndex = content.startIndex
        while currentIndex < content.endIndex {
            let character = String(content[currentIndex])
            if tupleSet.contains(character), let range = stack.push(expression: character,index:currentIndex) {
                rangeDict[range.lowerBound] = range
            }
            currentIndex = content.index(currentIndex, offsetBy: 1,limitedBy:content.endIndex) ?? content.endIndex
        }
        if !stack.isEmpty {
            throw ErrorType.invalidSyntax
        }
        return rangeDict
    }
}

