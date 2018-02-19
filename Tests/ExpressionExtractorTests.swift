import Foundation
import XCTest
import xcodeparserCore

class ExpressionExtractorTests : XCTestCase {

    func testThatItCanBeInitialised() {
        let parser = ExpressionExtractor(with: "{....}")
        XCTAssertNotNil(parser)
    }
    
    func testThatItCanParse() {
        let content = "{.}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        let range = result[content.startIndex]!
        let expression = String(content[range])
        XCTAssertEqual(expression, "{.}")
        XCTAssertEqual(range, content.startIndex...content.index(before:content.endIndex))
    }

    func testThatItCanParseWithExpressionAtTheEnd() {
        let content = "abc{.}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        let startIndex = content.index(content.startIndex,offsetBy:3)
        let range = result[startIndex]!
        let expression = String(content[range])
        XCTAssertEqual(expression, "{.}")
        XCTAssertEqual(range, startIndex...content.index(before:content.endIndex))
    }

    func testThatItCanParseWithExpressionAtTheBeginning() {
        let content = "{....}abc"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        let startIndex = content.startIndex
        let range = result[startIndex]!
        let expression = String(content[range])
        XCTAssertEqual(expression, "{....}")
        XCTAssertEqual(range, startIndex...content.index(content.endIndex, offsetBy: -4))
    }

    func testThatItCanParseComplexExpression() {
        let content = "{.....(abc)()()(){}{}{}}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        let startIndex = content.startIndex
        let range = result[startIndex]!
        let expression = String(content[range])
        XCTAssertEqual(expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(range, content.startIndex...content.index(before:content.endIndex))
    }

    func testThatItCanParseComplexExpressionAtTheEnd() {
        let content = "abc{.....(abc)()()(){}{}{}}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        let startIndex = content.index(content.startIndex,offsetBy:3)
        let range = result[startIndex]!
        let expression = String(content[range])
        XCTAssertEqual(expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(range, startIndex...content.index(before:content.endIndex))
    }

    func testThatItCanParseComplexExpressionAtTheBeginning() {
        let content = "{.....(abc)()()(){}{}{}}abc{{{{}}}}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        let startIndex = content.startIndex
        let range = result[startIndex]!
        let expression = String(content[range])
        XCTAssertEqual(expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(range, content.startIndex...content.index(content.endIndex,offsetBy:-12))
    }

    func testThatItShouldThrowIfSyntaxInvalid() {
        let parser = ExpressionExtractor(with: "{({})")
        XCTAssertThrowsError(try parser.parse()) { error in
            XCTAssertEqual(error as? ExpressionExtractor.ErrorType, ExpressionExtractor.ErrorType.invalidSyntax)
        }

    }
    
    
}
