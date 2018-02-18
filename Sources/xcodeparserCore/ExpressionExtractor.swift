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
    private lazy var stack = ExpressionStack(pairs: self.tupleSet)

    public  init(with content : String) {
        self.content = content
    }
    
    public func parse() throws -> (expression:String,range:Range<String.Index>)? {
        var currentIndex = content.startIndex
        while currentIndex < content.endIndex {
            let character = String(content[currentIndex])
            if tupleSet.contains(character)  {
                _ = stack.push(expression: character,index:currentIndex)
            }
            switch (state,stack.isEmpty) {
            case (.started(let startIndex),true):
                self.state = .end
                let endIndex = self.content.index(after:currentIndex)
                let range = startIndex..<endIndex
                let expression = String(self.content[range])
                return (expression,range)
            case (.searching,false):
                self.state = .started(currentIndex)
            default:
                break
            }
           
            currentIndex = content.index(after: currentIndex)
        }
        if case .started = state {
            throw ErrorType.invalidSyntax
        }
        return nil
    }
}
