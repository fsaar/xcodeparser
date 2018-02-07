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
                                    OBJ_11/* List */ = (
                                      value2,
                                        value3,
                                    );
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let value = (config["OBJ_10"] as! XcodeSimpleExpression).value
        let expression = config["OBJ_11"] as! XcodeListExpression
        let comment = expression.comment
        let valueList = expression.value
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(comment,"List ")
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
         let expression = config["children"] as! XcodeListExpression
        let valueList = expression.value
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
        let expression = config["OBJ_40"] as! XcodeDictionaryExpression
        let comment1 = expression.comment
        let dict = expression.value as! [String:XcodeSimpleExpression]
        let value1 = dict["isa"]!.value
        let value2 = dict["buildActionMask"]!.value
        let value3 = dict["runOnlyForDeploymentPostprocessing"]!.value
        XCTAssertEqual(value1,"PBXFrameworksBuildPhase")
        XCTAssertEqual(comment1,"Frameworks ")
        XCTAssertEqual(value2,"0")
        XCTAssertEqual(value3,"1")
    }

}
