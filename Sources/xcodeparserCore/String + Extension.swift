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
    
    func skip(_ characterSet : CharacterSet,with range: ClosedRange<String.Index>) -> String.Index {
        var currentIndex = range.lowerBound
        while currentIndex < range.upperBound, let character = self[currentIndex].unicodeScalars.first,characterSet.contains(character) {
            currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
        }
        return currentIndex
    }
    
    func value(at range: ClosedRange<String.Index>) -> (value:String,range:Range<String.Index>)?  {
        enum State {
            case scanValue
            case scanComment
            case end
        }
        var state : State = .scanValue
        var currentIndex = skip(.whitespaces,with: range)
        if self[currentIndex] == "{" || self[currentIndex] == "(" {
            return nil
        }
        let valueRangeStart = currentIndex
        var value : String?
        while currentIndex < range.upperBound {
            if let character = self[currentIndex].unicodeScalars.first, CharacterSet.newlines.contains(character) {
                return nil
            }
            switch state {
            case .scanValue:
                switch self[currentIndex] {
                case "|", "~","\"","_","-","+","*","#","<",">",".","$","?","!","[","]","&","@","A"..."Z","a"..."z","0"..."9",":":
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
                default:
                    value = String(self[valueRangeStart..<currentIndex])
                    currentIndex = skip(.whitespaces, with: currentIndex...range.upperBound)
                    state = .scanComment
                }
            case .scanComment:
                if let (_,commentRange) = self.comment(at: currentIndex...range.upperBound) {
                    let distance = self.distance(from: commentRange.lowerBound, to: commentRange.upperBound)
                    currentIndex = self.index(currentIndex, offsetBy: distance)
                }
                state = .end
            case .end:
                if self[currentIndex] == ";" {
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
                }
                currentIndex = skip(.whitespaces,with: currentIndex...range.upperBound)
                if let value = value {
                    return (value,range.lowerBound..<currentIndex)
                }
                else {
                    return nil
                }
            }
        }
        return nil
    }
    
    func keyValueStart(at range: ClosedRange<String.Index>) -> (key:String,comment: String?,range:Range<String.Index>)? {
        enum State {
            case scanKey
            case scanComment
            case end
        }
        var state : State = .scanKey
        var currentIndex = skip(.whitespacesAndNewlines,with: range)
        let keyRangeStart = currentIndex
        var key : String?
        var comment : String?
        while currentIndex < range.upperBound {
            if let character = self[currentIndex].unicodeScalars.first, CharacterSet.newlines.contains(character) {
                return nil
            }
            switch state {
            case .scanKey:
                switch self[currentIndex] {
                case "|", "~","\"","_","-","+","*","#","<",">",".","$","?","!","[","]","&","@","A"..."Z","a"..."z","0"..."9",":":
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
                default:
                    key = String(self[keyRangeStart..<currentIndex])
                    currentIndex = skip(.whitespaces, with: currentIndex...range.upperBound)
                    state = .scanComment
                }
            case .scanComment:
                if let (rangeComment,commentRange) = self.comment(at: currentIndex...range.upperBound) {
                    comment = rangeComment
                    let distance = self.distance(from: commentRange.lowerBound, to: commentRange.upperBound)
                    currentIndex = self.index(currentIndex, offsetBy: distance)
                }
                state = .end
            case .end:
                guard self[currentIndex] == "=", let key = key else {
                    return nil
                }
                currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
                currentIndex = skip(.whitespaces,with: currentIndex...range.upperBound)
                return (key,comment,range.lowerBound..<currentIndex)
            }
        }
        return nil
    }
    
    func comment(at range : ClosedRange<String.Index>) -> (comment:String?,range:Range<String.Index>)? {
        enum State {
            case scan
            case end
        }
        var currentIndex = range.lowerBound
        var state : State = .scan
        guard self[currentIndex...].hasPrefix("/*") else {
            return nil
        }
        let rangeStart = self.index(currentIndex, offsetBy: 2, limitedBy: range.upperBound) ?? range.upperBound
        while currentIndex < range.upperBound {
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
                    currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
                    currentIndex = skip(.whitespacesAndNewlines,with: currentIndex...range.upperBound)
                    return (comment,range.lowerBound..<currentIndex)
                }
                else
                {
                    state = .scan
                }
            }
            currentIndex =  self.index(currentIndex, offsetBy: 1, limitedBy: range.upperBound) ?? range.upperBound
        }
        return nil
    }
    
    func commentWithWhiteSpaceAndNewLines(at range: ClosedRange<String.Index>) -> (comment:String?,range:Range<String.Index>)? {
        let currentIndex = skip(.whitespacesAndNewlines,with: range)
        guard let tuple = comment(at: currentIndex...range.upperBound) else {
            return currentIndex != range.lowerBound ? (nil,range.lowerBound..<currentIndex) : nil
        }
        return tuple
    }
}

extension String {
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
