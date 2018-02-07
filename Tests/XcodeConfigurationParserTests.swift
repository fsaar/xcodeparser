import Foundation
import XCTest
import xcodeparserCore



class XcodeConfigurationParserTests : XCTestCase {
    func testThatItCanBeInitialised() throws {
        let parser = try! XcodeConfigurationParser(configuration:"""
        {
         "key" = "value"
        }
        """)
        XCTAssertNotNil(parser)
    }
    
    func testThatItShouldThrowWithAnEmptyConfiguration() {
        XCTAssertThrowsError(try XcodeConfigurationParser(configuration:"")) { error in
            XCTAssertEqual(error as? XcodeConfigurationParser.Result, XcodeConfigurationParser.Result.invalid)
        }
    }
    func testThatItShouldReadEmptyConfiguration() {
        let configString =  "{}"
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:String]
        XCTAssertEqual(config,[:])
    }

    func testThatItShouldReadAKeyValueConfiguration() {
        let configString =  """
                                {
                                    key = value;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:XcodeSimpleExpression]
        let key = config.keys.first!
        let value = config.values.first!.value
        XCTAssertEqual(value,"value")
        XCTAssertEqual(key,"key")
    }
    
    func testThatItShouldReadAKeyValueConfigurationWithInitialCommentsAtTheTop() {
        let configString =  """
                                // !$*UTF8*$!
                                {
                                    key = value;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:XcodeSimpleExpression]
        let key = config.keys.first!
        let value = config.values.first!.value
        XCTAssertEqual(value,"value")
        XCTAssertEqual(key,"key")
    }
    
    func testThatItShouldReadAKeyValueConfigurationWithMultipleEntries() {
        let configString =  """
                                {
                                    key1 = value1;
                                    key2 = value2;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:XcodeSimpleExpression]
        let value = config["key1"]!.value
        let value2 = config["key2"]!.value
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(value2,"value2")
    }
    
    func testThatItShouldReadAKeyValueConfigurationWithMultipleEntriesAndComments() {
        let configString =  """
                                {
                                    key1 = value1;
                                    key2 = value2;
                                    key3 = value3;
                                    key4 /* comment 4 */ = value4;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:XcodeSimpleExpression]
        let value = config["key1"]!.value
        let value2 = config["key2"]!.value
        let value3 = config["key3"]!.value
        let expression = config["key4"]!
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(value2,"value2")
        XCTAssertEqual(value3,"value3")
        XCTAssertEqual(expression,XcodeSimpleExpression(value:"value4",comment:"comment 4 "))
    }
    
    func testThatItShouldReadAListConfiguration() {
        let configString =  """
                                {
                                    OBJ_10 = value1;
                                    OBJ_11 = (
                                      value2,
                                        value3,
                                    );
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let value = (config["OBJ_10"] as! XcodeSimpleExpression).value
        let valueList = config["OBJ_11"] as! [XcodeSimpleExpression]
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(valueList,[XcodeSimpleExpression(value:"value2"),XcodeSimpleExpression(value:"value3")])
    }
    func testThatItShouldReadAListConfigurationWithComments() {
        let configString =  """
                                {
                                    key1 = value1;
                                    children = (
                                "xcodeparser::xcodeparserTests::Product" /* xcodeparserTests.xctest */,
                                "xcodeparser::xcodeparser::Product" /* xcodeparser */,
                                "xcodeparser::xcodeparserCore::Product" /* xcodeparserCore.framework */,
                                    );
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let value = (config["key1"] as! XcodeSimpleExpression).value
        let valueList = config["children"] as! [XcodeSimpleExpression]
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(valueList,[XcodeSimpleExpression(value:"\"xcodeparser::xcodeparserTests::Product\"",comment:"xcodeparserTests.xctest "),
                                    XcodeSimpleExpression(value:"\"xcodeparser::xcodeparser::Product\"",comment:"xcodeparser "),
                                    XcodeSimpleExpression(value:"\"xcodeparser::xcodeparserCore::Product\"",comment:"xcodeparserCore.framework ")])
    }

    func testThatItShouldReadADictionaryConfiguration() {
        let configString =  """
                                {
                                    OBJ_40 /* Frameworks */ = {
                                isa = PBXFrameworksBuildPhase;
                                                                buildActionMask = 0;
                                                                runOnlyForDeploymentPostprocessing = 1;
                                                                };
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let dict = config["OBJ_40"] as! [String:XcodeSimpleExpression]
        let value1 = dict["isa"]!.value
        let value2 = dict["buildActionMask"]!.value
        let value3 = dict["runOnlyForDeploymentPostprocessing"]!.value
        XCTAssertEqual(value1,"PBXFrameworksBuildPhase")
        XCTAssertEqual(value2,"0")
        XCTAssertEqual(value3,"1")
    }
    
    
//    func testThatItShouldReadAListConfiguration() {
//
//    }
//
//    func testThatItShouldReadADictionaryConfigurationWithSimpleKeyValues() {
//
//    }
//
//    func testThatItShouldReadADictionaryConfigurationWithAList() {
//
//    }
//
//    func testThatItShouldReadADictionaryConfigurationWithAnotherDictionary() {
//
//    }

    
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
