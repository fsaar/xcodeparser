import Foundation
import XCTest
import xcodeparserCore

class ExpressionStackTests : XCTestCase {
    var tupleSet : Set<ExpressionStackPair>!

    override func setUp() {
         tupleSet = Set([ExpressionStackPair(open: "{", close: "}"),ExpressionStackPair(open: "(", close: ")")])
    }
    
    func testThatItCanBeInitialised() {
        let stack = ExpressionStack(pairs:tupleSet)
        XCTAssertNotNil(stack)
    }
    
    func testThatItCanPush() {
        let string = "{"
        let stack = ExpressionStack(pairs:tupleSet)
        _ = stack.push(expression: string,index:string.startIndex)
        XCTAssertEqual(stack.isEmpty,false)
    }
    
    func testThatItShouldReturnNoRangeIfNoPairsMatched() {
        let string = "{"
        let stack = ExpressionStack(pairs:tupleSet)
        let range = stack.push(expression: string,index:string.startIndex)
        XCTAssertNil(range)
    }
    
    func testThatItCanMatchSimpleExpressions() {
        let string = "{}"
        let stack = ExpressionStack(pairs:tupleSet)
         let currentIndex0 = string.startIndex
        _ = stack.push(expression: String(string[currentIndex0]),index: currentIndex0)
        let currentIndex1 = string.index(after: currentIndex0)
        let range = stack.push(expression: String(string[currentIndex1]),index: currentIndex1)
        XCTAssertEqual(stack.isEmpty,true)
        XCTAssertEqual(range,string.startIndex...string.index(before: string.endIndex))
    }

    func testThatItCanMatchMoreComplexExpression() {
        let string = "{{(())}}"
        let stack = ExpressionStack(pairs:tupleSet)
        let currentIndex0 = string.startIndex
        _ = stack.push(expression: String(string[currentIndex0]),index:currentIndex0)
        let currentIndex1 = string.index(after: currentIndex0)
        _ = stack.push(expression: String(string[currentIndex1]),index:currentIndex1)
        let currentIndex2 = string.index(after: currentIndex1)
        _ = stack.push(expression: String(string[currentIndex2]),index:currentIndex2)
        let currentIndex3 = string.index(after: currentIndex2)
        _ = stack.push(expression: String(string[currentIndex3]),index:currentIndex3)
        let currentIndex4 = string.index(after: currentIndex3)
        let range0 = stack.push(expression: String(string[currentIndex4]),index:currentIndex4)
        XCTAssertEqual(range0, currentIndex3...currentIndex4)
        let currentIndex5 = string.index(after: currentIndex4)
        let range1 = stack.push(expression: String(string[currentIndex5]),index:currentIndex5)
        XCTAssertEqual(range1, currentIndex2...currentIndex5)
        let currentIndex6 = string.index(after: currentIndex5)
        let range2 = stack.push(expression: String(string[currentIndex6]),index:currentIndex6)
        XCTAssertEqual(range2, currentIndex1...currentIndex6)
        let currentIndex7 = string.index(after: currentIndex6)
        let range3 = stack.push(expression: String(string[currentIndex7]),index:currentIndex7)
        XCTAssertEqual(range3, string.startIndex...string.index(before: string.endIndex))
        XCTAssertEqual(stack.isEmpty,true)
    }

    func testThatItCollapsesCorrectly() {
        let string = "{((}"
        let stack = ExpressionStack(pairs:tupleSet)
        let currentIndex0 = string.startIndex
        _ = stack.push(expression: String(string[currentIndex0]),index:currentIndex0)
        let currentIndex1 = string.index(after: currentIndex0)
        _ = stack.push(expression: String(string[currentIndex1]),index:currentIndex1)
        let currentIndex2 = string.index(after: currentIndex1)
        _ = stack.push(expression: String(string[currentIndex2]),index:currentIndex2)
        let currentIndex3 = string.index(after: currentIndex2)
        _ = stack.push(expression: String(string[currentIndex3]),index:currentIndex3)
        XCTAssertEqual(stack.isEmpty,false)
    }
    
}
