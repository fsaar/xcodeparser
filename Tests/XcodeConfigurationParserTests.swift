import Foundation
import XCTest
import xcodeparserCore



class XcodeConfigurationParserTests : XCTestCase {
    func testThatItCanBeInitialised() throws {
        let parser = try! XcodeConfigurationParser(configuration:"""
        {
        
        }
        """)
        XCTAssertNotNil(parser)
    }
    
    func testThatItShouldThrowWithAnEmptyConfiguration() {
        XCTAssertThrowsError(try XcodeConfigurationParser(configuration:"")) { error in
            XCTAssertEqual(error as? XcodeConfigurationParser.Result, XcodeConfigurationParser.Result.invalid)
        }
    }
    func testThatItShouldReadAnEmptyConfiguration() {
        let configString =  "{}"
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:String]
        XCTAssertEqual(config,[:])
    }
//
//    func testThatItShouldReadAKeyValueConfiguration() {
//        let configString =  """
//                                {
//                                    "key" = "value"
//                                }
//                            """
//        let parser = XcodeSyntaxParser(configuration:configString)
//        let config = try! parser.parse() as! [String:String]
//        XCTAssertEqual(config["key"],"value")
//    }
    
    func testThatItShouldReadAListConfiguration() {
        
    }
    
    func testThatItShouldReadADictionaryConfigurationWithSimpleKeyValues() {
        
    }
    
    func testThatItShouldReadADictionaryConfigurationWithAList() {
        
    }
    
    func testThatItShouldReadADictionaryConfigurationWithAnotherDictionary() {
        
    }

    
//    func testThatItShouldShowHelpIfHelpOptionGiven() {
//        let parser = CommandLineParser(arguments: ["","--help"])
//        let tuple = try! parser.parseCommandLine()
//        let expectation : CommandlineParserReturnValue = (nil,nil,.help)
//        XCTAssert(tuple == expectation)
//    }
//
//    func testThatItShouldShowHelpAndIgnoreOtherArgumentsIfGiven() {
//        let parser = CommandLineParser(arguments: ["","--help","..","--limit","100"])
//        let tuple = try! parser.parseCommandLine()
//        let expectation : CommandlineParserReturnValue = (nil,nil,.help)
//        XCTAssert(tuple == expectation)
//    }
//
//    func testThatItShouldShowInvalidArgumentsIf1ArgumentGiven() {
//        let parser = CommandLineParser(arguments: [""])
//
//        XCTAssertThrowsError(try parser.parseCommandLine()) { error in
//            XCTAssertEqual(error as? CommandLineParser.Result, CommandLineParser.Result.notEnoughArguments)
//        }
//    }
//
//    func testThatItShouldShowInvalidArgumentsIf2ArgumentsGiven() {
//        let parser = CommandLineParser(arguments: ["",".."])
//
//        XCTAssertThrowsError(try parser.parseCommandLine()) { error in
//            XCTAssertEqual(error as? CommandLineParser.Result, CommandLineParser.Result.notEnoughArguments)
//        }
//    }
//
//    func testThatItShouldShowInvalidArgumentsIf3ArgumentsGiven() {
//        let parser = CommandLineParser(arguments: ["","..","--limit"])
//
//        XCTAssertThrowsError(try parser.parseCommandLine()) { error in
//            XCTAssertEqual(error as? CommandLineParser.Result, CommandLineParser.Result.notEnoughArguments)
//        }
//    }
//
//    func testThatItShouldReturnPathAndLimitIfGiven() {
//        let path = FileManager.default.currentDirectoryPath
//        let parser = CommandLineParser(arguments: ["",path,"--limit","100"])
//        let tuple = try! parser.parseCommandLine()
//        let expectation : CommandlineParserReturnValue = (URL(fileURLWithPath: path),100,nil)
//        XCTAssert(tuple == expectation)
//
//    }
//
//    func testThatItShouldThrowInvalidFormatIf2ndArgumentNotLimit() {
//        let path = FileManager.default.currentDirectoryPath
//        let parser = CommandLineParser(arguments: ["",path,"--somethingelse","100"])
//        XCTAssertThrowsError(try parser.parseCommandLine()) { error in
//            XCTAssertEqual(error as? CommandLineParser.Result, CommandLineParser.Result.invalidFormat)
//        }
//
//    }
//
//    func testThatItShouldReturnTheCorrectFileRestrictionIfGivenSwift() {
//        let path = FileManager.default.currentDirectoryPath
//        let parser = CommandLineParser(arguments: ["",path,"--limit","100","--swift"])
//        let tuple = try! parser.parseCommandLine()
//        let expectation : CommandlineParserReturnValue = (URL(fileURLWithPath: path),100,.swift)
//        XCTAssert(tuple == expectation)
//
//    }
//
//    func testThatItShouldReturnTheCorrectFileRestrictionIfGivenObjectiveC() {
//        let path = FileManager.default.currentDirectoryPath
//        let parser = CommandLineParser(arguments: ["",path,"--limit","100","--objc"])
//        let tuple = try! parser.parseCommandLine()
//        let expectation : CommandlineParserReturnValue = (URL(fileURLWithPath: path),100,.objc)
//        XCTAssert(tuple == expectation)
//
//    }
}
