//
//  XcodeExpression.swift
//  xcodeparserPackageDescription
//
//  Created by Frank Saar on 08/02/2018.
//

import Foundation

public protocol XcodeExpression {
    associatedtype T
    var value : T { get }
    var comment : String? { get }
}

public struct XcodeGenericExpression<T : Equatable> : Equatable,XcodeExpression {
    public let value : T
    public let comment : String?
    public init (value: T,comment: String? = nil) {
        self.value = value
        self.comment = comment
    }
    static public func ==(lhs : XcodeGenericExpression,rhs : XcodeGenericExpression) -> Bool {
        return lhs.value == rhs.value && lhs.comment == rhs.comment
    }
}

public typealias XcodeSimpleExpression = XcodeGenericExpression<String>
public typealias XcodeListExpression = XcodeGenericExpression<[XcodeGenericExpression<String>]>

public struct XcodeDictionaryExpression : XcodeExpression {
    public let value : [String:Any]
    public let comment : String?
    public init (value: [String:Any],comment: String? = nil) {
        self.value = value
        self.comment = comment
    }
}

