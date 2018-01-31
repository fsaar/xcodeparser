import Foundation
import XCTest
import xcodeparserCore

class ExpressionExtractorTests : XCTestCase {

    func testThatItCanBeInitialised() {
        let parser = ExpressionExtractor(with: "{....}")
        XCTAssertNotNil(parser)
    }
    
    func testThatItCanParse() {
        let parser = ExpressionExtractor(with: "{.}")
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.}")
        XCTAssertEqual(result!.remainder, "")
    }
    
    func testThatItCanParseWithExpressionAtTheEnd() {
        let parser = ExpressionExtractor(with: "abc{.}")
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.}")
        XCTAssertEqual(result!.remainder, "")
    }
    
    func testThatItCanParseWithExpressionAtTheBeginning() {
        let parser = ExpressionExtractor(with: "{....}abc")
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{....}")
        XCTAssertEqual(result!.remainder, "abc")
    }
    
    func testThatItCanParseComplexExpression() {
        let parser = ExpressionExtractor(with: "{.....(abc)()()(){}{}{}}")
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(result!.remainder, "")
    }
    
    func testThatItCanParseComplexExpressionAtTheEnd() {
        let parser = ExpressionExtractor(with: "abc{.....(abc)()()(){}{}{}}")
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(result!.remainder, "")
    }
    
    func testThatItCanParseComplexExpressionAtTheBeginning() {
        let parser = ExpressionExtractor(with: "{.....(abc)()()(){}{}{}}abc{{{{}}}}")
        let result = try! parser.parse()
        XCTAssertEqual(result!.expression, "{.....(abc)()()(){}{}{}}")
        XCTAssertEqual(result!.remainder, "abc{{{{}}}}")
    }
    
    func testThatItShouldThrowIfSyntaxInvalid() {
        let parser = ExpressionExtractor(with: "{({})")
        XCTAssertThrowsError(try parser.parse()) { error in
            XCTAssertEqual(error as? ExpressionExtractor.ErrorType, ExpressionExtractor.ErrorType.invalidSyntax)
        }
        
    }
    
    
}
