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

public struct Expression  : Hashable{
    let index : String.Index
    let string : String
    
    init(string : String, index : String.Index) {
        self.string = string
        self.index = index
    }
    
    public static func ==(lhs : Expression,rhs : Expression) -> Bool {
        return lhs.string == rhs.string
    }
    public var hashValue: Int {
        return string.hashValue
    }
}

public class ExpressionStack {
 
    private var stack : [Expression] = []
    private var pairs : Set<ExpressionStackPair> = []
    public init(pairs: Set<ExpressionStackPair>) {
        self.pairs = pairs
    }
    
    public  func push(expression : String,index : String.Index) -> ClosedRange<String.Index>? {
        var range : ClosedRange<String.Index>? = nil
        (stack,range) =  match(stack:stack + [Expression(string: expression, index: index) ])
        return range
    }
    
    public var isEmpty : Bool {
        return self.stack.isEmpty
    }
}

fileprivate extension ExpressionStack {
    func match(stack : [Expression]) -> (stack:[Expression],range:ClosedRange<String.Index>?) {
        let suffix = stack.suffix(2)
        guard suffix.count == 2,let open = suffix.first,let close = suffix.last else {
            return (stack,nil)
        }
        let pair = ExpressionStackPair(open: open.string, close: close.string)
        if pairs.contains(pair) {
            let range = open.index...close.index
            return (Array(stack.prefix(stack.count-2)),range)
        }
        return  (stack,nil)
    }
}
