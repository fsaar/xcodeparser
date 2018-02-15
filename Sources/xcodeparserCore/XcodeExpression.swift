//
//  XcodeExpression.swift
//  xcodeparserPackageDescription
//
//  Created by Frank Saar on 08/02/2018.
//

import Foundation

public protocol XcodeExpressionProtocol {
    associatedtype T
    var value : T { get }
    var comment : String? { get }
}

public struct XcodeGenericExpression<T : Equatable> : Equatable,XcodeExpressionProtocol {
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

public struct XcodeDictionaryExpression : XcodeExpressionProtocol {
    public let value : [String:XcodeExpression]
    public let comment : String?
    public init (value: [String:XcodeExpression],comment: String? = nil) {
        self.value = value
        self.comment = comment
    }
}

public enum XcodeExpression {
    case assignment(expression : XcodeSimpleExpression)
    case dictionary(expression : XcodeDictionaryExpression)
    case array(expression : XcodeListExpression)
   
    public var value : Any? {
        switch self {
        case let .assignment(e):
            return e as Any
        case let .dictionary(e):
            return e as Any
        case let .array(e):
            return e as Any
        }
    }
    public var string : String? {
        guard case .assignment(let e) = self else {
            return nil
        }
        return e.value
    }
    public var dict : [String:XcodeExpression]? {
        guard case .dictionary(let e) = self else {
            return nil
        }
        return e.value
    }
    public var stringList : [String]? {
        guard case .array(let e) = self else {
            return nil
        }
        return e.value.map { $0.value }
    }
}



