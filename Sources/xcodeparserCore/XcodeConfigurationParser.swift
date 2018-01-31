//
//  CommandLineParser.swift
//  filesizePackageDescription
//
//  Created by Frank Saar on 21/12/2017.
//

import Foundation

enum Regex : String {
    case dictionary = "\\{.*\\}"
    case keyValue = "\\s*(\"\\w*\")\\s*=\\s*(\"\\w*\")\\s*;\\s*"
}

struct XcodeConfigurationExpressionParser : Sequence {
    var currentIndex : String.Index
    let configuration  : String
    public init?(with xcodeProject: String) {
        configuration = xcodeProject
        currentIndex = configuration.startIndex
    }
    
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            guard self.currentIndex < self.configuration.endIndex else {
                return nil
            }
            
            return ""
        }
    }
}


public class XcodeConfigurationParser {
    public enum Result : Error {
        case invalid
    }
    
    let configuration : String
    public init(configuration : String) throws {
        let content = configuration.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            throw Result.invalid
        }
        self.configuration = configuration.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let tuple = applyExpression(Regex.dictionary.rawValue, to: content),let _ = tuple.object as? [String:Any] else {
            throw Result.invalid
        }
    }
    
    public func parse() throws  -> [String : Any] {
        
        var objects : [String: Any] = [:]
     //   content.split(separator: "\n").forEach { line in
//            if let object = applyExpression(Regex.keyValue.rawValue, to: String(line))?.object as [String:] {
//                objects += [object]
//            }
      //  }
    
        return objects
    }
}
//
extension XcodeConfigurationParser {
    func applyExpression(_ expression : String,to string: String) -> (object:Any,content:String)? {
        guard let dictRegex = try? NSRegularExpression(pattern: expression, options: [.dotMatchesLineSeparators]) else {
            return nil
        }
        let matches = dictRegex.matches(in: string, options: [], range: NSMakeRange(0, string.count))
        guard let result = matches.first else {
            return nil
        }
        let range = result.range
        let startIndex = string.index(string.startIndex, offsetBy: range.location)
        let endIndex = string.index(startIndex,offsetBy: range.length)
        let object : [String: Any] = [:]
        let content = "\(string[string.index(after: startIndex)..<string.index(before: endIndex)])"
        return (object as Any,content)
    }
}
