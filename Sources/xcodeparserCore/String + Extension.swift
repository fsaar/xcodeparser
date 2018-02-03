//
//  String + Extension.swift
//  xcodeparserPackageDescription
//
//  Created by Frank Saar on 03/02/2018.
//

import Foundation

enum Regex : String {
    case keyCommentEqualComment = "^(\\s*(\\w+)\\s*(\\/\\*[\\s\\w]*\\*\\/)?\\s*=\\s*).*$"
    case value = "((\\w+)\\s*;\\s*$)"
}

extension String {
    
    func range(from nsrange : NSRange) -> Range<String.Index>? {
        guard nsrange.location != NSNotFound else {
            return nil
        }
        let matchStartIndex = self.index(startIndex, offsetBy: nsrange.location)
        let matchEndIndex = self.index(matchStartIndex,offsetBy: nsrange.length)
        return matchStartIndex..<matchEndIndex
    }
    
    func value() -> (value:String,range:Range<String.Index>)?  {
        guard let dictRegex = try? NSRegularExpression(pattern: Regex.value.rawValue, options: [.anchorsMatchLines]) else {
            return nil
        }
        let matches = dictRegex.matches(in: self, options: [], range: NSMakeRange(0, count))
        guard let result = matches.first,result.numberOfRanges > 1 else {
            return nil
        }
        guard let range = self.range(from: result.range(at: 1)),let matchedValueRange = self.range(from: result.range(at: 2) ) else {
            return nil
        }
        let value = String(self[matchedValueRange])
        return (value,range)
    }
    
    func keyValueStart() -> (key:String,comment: String?,range:Range<String.Index>)? {
        guard let dictRegex = try? NSRegularExpression(pattern: Regex.keyCommentEqualComment.rawValue, options: [.anchorsMatchLines]) else {
            return nil
        }
        let matches = dictRegex.matches(in: self, options: [], range: NSMakeRange(0, count))
        guard let result = matches.first,result.numberOfRanges > 1 else {
            return nil
        }
        guard let range = self.range(from: result.range(at: 1)),let matchedKeyRange = self.range(from: result.range(at: 2) ) else {
            return nil
        }
        let key = String(self[matchedKeyRange])
        
        var comment : String?
        if result.numberOfRanges > 2,let matchedCommentRange = self.range(from: result.range(at: 3) ) {
            comment = String(self[matchedCommentRange])
        }
        return (key,comment,range)
    }
}
