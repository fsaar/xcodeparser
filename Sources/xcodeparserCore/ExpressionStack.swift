//
//  ExpressionStack.swift
//
//  Created by Frank Saar on 29/01/2018.
//

import Foundation

public extension Sequence where Element == ExpressionStackPair {
    public  func list() -> [String] {
        return self.reduce([]) { $0 + [$1.open,$1.close] }
    }
    
    public  func contains(_ string : String) -> Bool {
        return list().contains(string)
    }
}

public struct ExpressionStackPair : Hashable {
    let open : String
    let close: String
    
    public init(open : String,close:String) {
        (self.open,self.close) = (open,close)
    }
    
    public static func ==(lhs : ExpressionStackPair,rhs : ExpressionStackPair) -> Bool {
        return lhs.open == rhs.open && lhs.close == rhs.close
    }
    public var hashValue: Int {
        return "\(open)|\(close)".hashValue
    }
}

public class ExpressionStack {
 
    private var stack : [String] = []
    private var pairs : Set<ExpressionStackPair> = []
    public init(pairs: Set<ExpressionStackPair>) {
        self.pairs = pairs
    }
    
    public func push(expression : String) {
        stack =  match(stack:stack + [expression])
    }
    
    public var isEmpty : Bool {
        return self.stack.isEmpty
    }
}

fileprivate extension ExpressionStack {
    func match(stack : [String]) -> [String] {
        guard stack.count > 1 else {
            return stack
        }
        let open = stack[stack.count-2]
        let close = stack[stack.count-1]
        let pair = ExpressionStackPair(open: open, close: close)
        if pairs.contains(pair) {
            return Array(stack.dropLast().dropLast())
        }
        return  stack
    }
}
