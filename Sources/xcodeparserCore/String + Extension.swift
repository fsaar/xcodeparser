//
//  String + Extension.swift
//
//  Created by Frank Saar on 03/02/2018.
//

import Foundation

enum Regex : String {
    case keyCommentEqualComment = "^(\\s*(\\w+)\\s*(\\/\\*\\s*([\\s\\w]*)\\*\\/)?\\s*=\\s*).*$"
    case value = "^\\s*(([\":\\w]+)\\s*;\\s*$)"
    case listValue = "[{(]?\\s*([\":\\w]+)\\s*(\\/\\*\\s*([\\s\\w\\.]*)\\*\\/)?\\s*[)},]?"
}

extension String {
    
    func index(index : String.Index, after range: Range<String.Index>) -> String.Index {
        let distance = self.distance(from: range.lowerBound, to: range.upperBound)
        let newIndex = self.index(index, offsetBy: distance)
        return newIndex
    }
    
    func value() -> (value:String,range:Range<String.Index>)?  {
        guard let dictRegex = try? NSRegularExpression(pattern: Regex.value.rawValue, options: [.anchorsMatchLines]) else {
            return nil
        }
        let matches = dictRegex.matches(in: self, options: [], range: NSMakeRange(0, count))
        guard let result = matches.first,result.numberOfRanges > 1 else {
            return nil
        }
        guard let range = Range(result.range(at: 1),in:self),let matchedValueRange = Range(result.range(at: 2),in:self ) else {
            return nil
        }
        let value = String(self[matchedValueRange])
        return (value,range)
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
            let matchedValueRange = Range(result.range(at: 1),in:self) else {
                return nil
        }
        let value = String(self[matchedValueRange])
        var comment : String?
        if result.numberOfRanges > 2,let matchedCommentRange = Range(result.range(at: 3),in:self ) {
            comment = String(self[matchedCommentRange])
        }
        return (value,comment,fullRange)
    }
    
    
    func keyValueStart() -> (key:String,comment: String?,range:Range<String.Index>)? {
        guard let dictRegex = try? NSRegularExpression(pattern: Regex.keyCommentEqualComment.rawValue, options: [.anchorsMatchLines]) else {
            return nil
        }
        let matches = dictRegex.matches(in: self, options: [], range: NSMakeRange(0, count))
        guard let result = matches.first,result.numberOfRanges > 1 else {
            return nil
        }
        guard let range = Range(result.range(at: 1),in:self),let matchedKeyRange = Range(result.range(at: 2),in:self ) else {
            return nil
        }
        let key = String(self[matchedKeyRange])
        
        var comment : String?
        if result.numberOfRanges > 3,let matchedCommentRange = Range(result.range(at: 4),in:self ) {
            comment = String(self[matchedCommentRange])
        }
        return (key,comment,range)
    }
}