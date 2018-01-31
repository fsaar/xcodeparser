//
//  XcodeExpressionExtractor.swift
//  xcodeparserPackageDescription
//
//  Created by Frank Saar on 29/01/2018.
//

import Foundation

public typealias ExpressionExtractorResult = (expression:String,remainder:String)


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
    private let tupleSet = Set([ExpressionStackPair(yin: "{", yang: "}"),ExpressionStackPair(yin: "(", yang: ")")])
    private lazy var stack = ExpressionStack(pairs: self.tupleSet)

    public  init(with content : String) {
        self.content = content
    }
    
    public func parse() throws -> ExpressionExtractorResult? {
        var currentIndex = content.startIndex
        while currentIndex < content.endIndex {
            let character = String(content[currentIndex])
            if tupleSet.contains(character)  {
                stack.push(expression: character)
            }
            switch (state,stack.isEmpty) {
            case (.started(let startIndex),true):
                self.state = .end
                let expression = String(self.content[startIndex...currentIndex])
                let index = content.index(after: currentIndex)
                let remainder = String(self.content[index..<content.endIndex])
                return (expression,remainder)
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
