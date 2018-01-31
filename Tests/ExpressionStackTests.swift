import Foundation
import XCTest
import xcodeparserCore

class ExpressionStackTests : XCTestCase {
    var tupleSet : Set<ExpressionStackPair>!

    override func setUp() {
         tupleSet = Set([ExpressionStackPair(yin: "{", yang: "}"),ExpressionStackPair(yin: "(", yang: ")")])
    }
    
    func testThatItCanBeInitialised() {
        let stack = ExpressionStack(pairs:tupleSet)
        XCTAssertNotNil(stack)
    }
    
    func testThatItCanPush() {
        let stack = ExpressionStack(pairs:tupleSet)
        stack.push(expression: "{")
        XCTAssertEqual(stack.isEmpty,false)
    }
    
    func testThatItCanMatchSimpleExpressions() {
        let stack = ExpressionStack(pairs:tupleSet)
        stack.push(expression: "{")
        stack.push(expression: "}")
        XCTAssertEqual(stack.isEmpty,true)
    }
    
    func testThatItCanMatchMoreComplexExpression() {
        let stack = ExpressionStack(pairs:tupleSet)
        stack.push(expression: "{")
        stack.push(expression: "{")
        stack.push(expression: "(")
        stack.push(expression: "(")
        stack.push(expression: ")")
        stack.push(expression: ")")
        stack.push(expression: "}")
        stack.push(expression: "}")
        XCTAssertEqual(stack.isEmpty,true)
    }
    
    func testThatItCollapsesCorrectly() {
        let stack = ExpressionStack(pairs:tupleSet)
        stack.push(expression: "{")
        stack.push(expression: "(")
        stack.push(expression: "(")
        stack.push(expression: "}")
        XCTAssertEqual(stack.isEmpty,false)
    }
    
}
