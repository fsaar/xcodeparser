//
//  XcodeExpressionExtractor.swift
//  xcodeparserPackageDescription
//
//  Created by Frank Saar on 29/01/2018.
//

import Foundation

public extension Sequence where Element == ExpressionStackPair {
    public  func list() -> [String] {
        return self.reduce([]) { $0 + [$1.yin,$1.yang] }
    }
    
    public  func contains(_ string : String) -> Bool {
        return list().contains(string)
    }
}

public struct ExpressionStackPair : Hashable {
    let yin : String
    let yang: String
    
    public init(yin : String,yang:String) {
        (self.yin,self.yang) = (yin,yang)
    }
    
    public static func ==(lhs : ExpressionStackPair,rhs : ExpressionStackPair) -> Bool {
        return lhs.yin == rhs.yin && lhs.yang == rhs.yang
    }
    public var hashValue: Int {
        return "\(yin)|\(yang)".hashValue
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
        let yin = stack[stack.count-2]
        let yang = stack[stack.count-1]
        let pair = ExpressionStackPair(yin: yin, yang: yang)
        if pairs.contains(pair) {
            return Array(stack.dropLast().dropLast())
        }
        return  stack
    }
}
