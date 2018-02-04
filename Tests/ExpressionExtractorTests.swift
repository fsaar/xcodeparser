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
        XCTAssertEqual(result!.expression, "{.}")
        XCTAssertEqual(result!.range, content.startIndex..<content.endIndex)
    }
    
    func testThatItCanParseWithExpressionAtTheEnd() {
        let content = "abc{.}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.}")
        XCTAssertEqual(result!.range, content.index(content.startIndex,offsetBy:3)..<content.endIndex)
    }
    
    func testThatItCanParseWithExpressionAtTheBeginning() {
        let content = "{....}abc"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{....}")
        XCTAssertEqual(result!.range, content.startIndex..<content.index(content.endIndex,offsetBy:-3))
    }
    
    func testThatItCanParseComplexExpression() {
        let content = "{.....(abc)()()(){}{}{}}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(result!.range, content.startIndex..<content.endIndex)
    }
    
    func testThatItCanParseComplexExpressionAtTheEnd() {
        let content = "abc{.....(abc)()()(){}{}{}}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(result!.range, content.index(content.startIndex,offsetBy:3)..<content.endIndex)
    }
    
    func testThatItCanParseComplexExpressionAtTheBeginning() {
        let content = "{.....(abc)()()(){}{}{}}abc{{{{}}}}"
        let parser = ExpressionExtractor(with: content)
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(result!.range, content.startIndex..<content.index(content.endIndex,offsetBy:-11))
    }
    
    func testThatItShouldThrowIfSyntaxInvalid() {
        let parser = ExpressionExtractor(with: "{({})")
        XCTAssertThrowsError(try parser.parse()) { error in
            XCTAssertEqual(error as? ExpressionExtractor.ErrorType, ExpressionExtractor.ErrorType.invalidSyntax)
        }
        
    }
    
    
}
