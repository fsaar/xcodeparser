//
//  String + Extension.swift
//
//  Created by Frank Saar on 03/02/2018.
//

import Foundation

enum Regex : String {
    case listValue = "[{(]?\\s*((\"\\$\\([:.\\w\\d\\/<>]+\\)[:.\\w\\d\\/<>]*\")|(\"[:.\\w\\d\\/<>]+\")|([:.\\w\\d\\/<>]+))\\s*(\\/\\*\\s*([\":\\s\\w\\d-\\.+-\\]\\[]*)\\*\\/)?\\s*[)},]?" // [{(]? + \s + "$variableValue" OR "Value" OR Value + \s + comment + \s + [)},]?
}


extension Substring {
    func index(index : String.Index, after range: Range<String.Index>) -> String.Index {
        let distance = self.distance(from: range.lowerBound, to: range.upperBound)
        let newIndex = self.index(index, offsetBy: distance)
        return newIndex
    }
    
    func innerRange(of range : ClosedRange<String.Index>) -> ClosedRange<String.Index> {
        guard self.distance(from: range.lowerBound, to: range.upperBound) > 1 else {
            return range
        }
        let lowerBound = self.index(after: range.lowerBound)
        let upperBound = self.index(before: range.upperBound)
        return lowerBound...upperBound
    }
}
extension String {
    
    
    func skip(_ characterSet : CharacterSet,at index: String.Index) -> String.Index {
        var currentIndex = index
        while currentIndex < self.endIndex, let character = self[currentIndex].unicodeScalars.first,characterSet.contains(character) {
            currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
        }
        return currentIndex
    }

    func value() -> (value:String,range:Range<String.Index>)?  {
        enum State {
            case scanValue
            case scanComment
            case end
        }
        var state : State = .scanValue
        var currentIndex = skip(.whitespaces,at: self.startIndex)
        if self[currentIndex] == "{" || self[currentIndex] == "(" {
            return nil
        }
        let valueRangeStart = currentIndex
        var value : String?
        while currentIndex < self.endIndex {
            if let character = self[currentIndex].unicodeScalars.first, CharacterSet.newlines.contains(character) {
                return nil
            }
            switch state {
            case .scanValue:
                switch self[currentIndex] {
                case "|", "~","\"","_","-","+","*","#","<",">",".","$","?","!","[","]","&","@","A"..."Z","a"..."z","0"..."9",":":
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
                default:
                    value = String(self[valueRangeStart..<currentIndex])
                    currentIndex = skip(.whitespaces, at: currentIndex)
                    state = .scanComment
                }
            case .scanComment:
                if let (_,commentRange) = self.comment(at: currentIndex) {
                    let distance = self.distance(from: commentRange.lowerBound, to: commentRange.upperBound)
                    currentIndex = self.index(currentIndex, offsetBy: distance)
                }
                state = .end
            case .end:
                if self[currentIndex] == ";" {
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
                }
                currentIndex = skip(.whitespaces,at: currentIndex)
                if let value = value {
                    return (value,self.startIndex..<currentIndex)
                }
                else {
                    return nil
                }
            }
        }
        return nil
    }
    
    func keyValueStart() -> (key:String,comment: String?,range:Range<String.Index>)? {
        enum State {
            case scanKey
            case scanComment
            case end
        }
        var state : State = .scanKey
        var currentIndex = skip(.whitespacesAndNewlines,at: self.startIndex)
        let keyRangeStart = currentIndex
        var key : String?
        var comment : String?
        while currentIndex < self.endIndex {
            if let character = self[currentIndex].unicodeScalars.first, CharacterSet.newlines.contains(character) {
                return nil
            }
            switch state {
            case .scanKey:
                switch self[currentIndex] {
                case "|", "~","\"","_","-","+","*","#","<",">",".","$","?","!","[","]","&","@","A"..."Z","a"..."z","0"..."9",":":
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
                default:
                    key = String(self[keyRangeStart..<currentIndex])
                    currentIndex = skip(.whitespaces, at: currentIndex)
                    state = .scanComment
                }
            case .scanComment:
                if let (rangeComment,commentRange) = self.comment(at: currentIndex) {
                    comment = rangeComment
                    let distance = self.distance(from: commentRange.lowerBound, to: commentRange.upperBound)
                    currentIndex = self.index(currentIndex, offsetBy: distance)
                }
                state = .end
            case .end:
                guard self[currentIndex] == "=", let key = key else {
                    return nil
                }
                currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
                currentIndex = skip(.whitespaces,at: currentIndex)
                return (key,comment,self.startIndex..<currentIndex)
            }
        }
        return nil
    }
    
    func comment(at index : String.Index) -> (comment:String?,range:Range<String.Index>)? {
        enum State {
            case scan
            case end
        }
        var currentIndex = index
        var state : State = .scan
        guard self[currentIndex...].hasPrefix("/*") else {
            return nil
        }
        let rangeStart = self.index(currentIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
        while currentIndex < self.endIndex {
            if let character = self[currentIndex].unicodeScalars.first, CharacterSet.newlines.contains(character) {
                return nil
            }
            switch state {
            case .scan:
                if case "*" = self[currentIndex] {
                    state = .end
                }
            case .end:
                if case "/" = self[currentIndex] {
                    let rangeEnd = self.index(currentIndex, offsetBy: -1)
                    let comment = String(self[rangeStart..<rangeEnd])
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
                    currentIndex = skip(.whitespacesAndNewlines,at: currentIndex)
                    return (comment,index..<currentIndex)
                }
                else
                {
                    state = .scan
                }
            }
            currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: self.endIndex) ?? self.endIndex
        }
        return nil
    }
    
    func commentWithWhiteSpaceAndNewLines() -> (comment:String?,range:Range<String.Index>)? {
        let currentIndex = skip(.whitespacesAndNewlines,at: self.startIndex)
        return comment(at: currentIndex)
    }
    

    func listValue() -> (value:String,comment: String?,range:Range<String.Index>)?  {
        guard let dictRegex = try? NSRegularExpression(pattern: Regex.listValue.rawValue, options: [.anchorsMatchLines]) else {
            return nil
        }
        let matches = dictRegex.matches(in: self, options: [], range: NSMakeRange(0, count))
        guard let result = matches.first, result.numberOfRanges > 0 else {
            return nil
        }
        
        guard let fullRange = Range(result.range(at: 0),in:self),
            let matchedValueRange = Range(result.range(at: 2),in:self) ?? Range(result.range(at: 3),in:self) ?? Range(result.range(at: 4),in:self) else {
                return nil
        }
        let value = String(self[matchedValueRange])
        var comment : String?
        if result.numberOfRanges > 5,let matchedCommentRange = Range(result.range(at: 6),in:self ) {
            comment = String(self[matchedCommentRange])
        }
        return (value,comment,fullRange)
    }
}
