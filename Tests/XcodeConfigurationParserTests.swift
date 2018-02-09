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
    
    func testThatItShouldReadAKeyValueConfigurationWithQuotes() {
        let configString =  """
                                {
                                    key = "xcodeparser::xcodeparserCore";
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:XcodeSimpleExpression]
        let key = config.keys.first!
        let value = config.values.first!.value
        XCTAssertEqual(value,"\"xcodeparser::xcodeparserCore\"")
        XCTAssertEqual(key,"key")
    }
    
    func testThatItShouldReadAKeyValueConfigurationWithInitialCommentsAtTheTop() {
        let configString =  """
                                // !$*UTF8*$!
                                {
                                     isa = PBXBuildFile;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse() as! [String:XcodeSimpleExpression]
        let key = config.keys.first!
        let value = config.values.first!.value
        XCTAssertEqual(key,"isa")
        XCTAssertEqual(value,"PBXBuildFile")
    }
    
    func testThatItShouldReadAKeyValueConfigurationWithAnEmptyDictionary() {
        let configString =  """
                               
                                {
                                     classes = {};
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let key = config.keys.first!
        let dict = config["classes"] as! XcodeDictionaryExpression
        XCTAssertEqual(key,"classes")
        XCTAssertEqual(dict.value.keys.isEmpty, true)
       
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
                                    key4 /* comment_ 4 */ = value4;
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
        XCTAssertEqual(expression,XcodeSimpleExpression(value:"value4",comment:"comment_ 4 "))
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
    
    func testThatItShouldReadAListConfigurationWithDifferentListCharacterSequences() {
        let configString =  """
                                {
                                    OBJ_10 = (
                                      "$(inherited)",
                                        "inherited2",
                                        inherited3
                                    );
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let valueList = (config["OBJ_10"] as! XcodeListExpression).value
        XCTAssertEqual(valueList,[XcodeSimpleExpression(value:"\"$(inherited)\""),XcodeSimpleExpression(value:"\"inherited2\""),XcodeSimpleExpression(value:"inherited3")])
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
    

    
    func testThatItShouldReadANestedDictionaryConfiguration() {
        let configString =  """
                                {
                                    OBJ_44 /* Debug */ = {
                                        buildSettings = {
                                            ENABLE_TESTABILITY = YES;
                                            FRAMEWORK_SEARCH_PATHS = (
                                                    "$(inherited)",
                                                    "$(PLATFORM_DIR)/Developer/Library/Frameworks",
                                            );
                                        };
                                    };
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let expression = config["OBJ_44"] as! XcodeDictionaryExpression
        let obj_44 = expression.value
        let comment1 = expression.comment
        let buildSettings = obj_44["buildSettings"] as! XcodeDictionaryExpression
        let testability = buildSettings.value["ENABLE_TESTABILITY"] as! XcodeSimpleExpression
        let searchPaths = buildSettings.value["FRAMEWORK_SEARCH_PATHS"] as! XcodeListExpression
        let searchPathsList = searchPaths.value
        let paths = searchPathsList.map { $0.value }
        XCTAssertEqual(comment1,"Debug ")
        XCTAssertEqual(testability.value,"YES")
        XCTAssertEqual(paths, ["\"$(inherited)\"",
                               "\"$(PLATFORM_DIR)/Developer/Library/Frameworks\""])
    }
    
    //                                    archiveVersion = 1;
    //                                    classes = {
    //                                    };
    //                                    objectVersion = 46;
    func testThatItShouldRealConfigurationExampleCorrectly() {
        let configString = """
                                // !$*UTF8*$!
                                {
                                    archiveVersion = 1;
                                    classes = {
                                    };
                                    objectVersion = 46;
                                    objects = {
                                        
                                        2C659326B6D6A9829EDDAFC3 = {isa = PBXBuildFile; fileRef = E391093442B4E54575D4146B /* Pods_tflApp_Tests.framework */; };
                                        412222F26B670B4DE4DA2909 /* libPods-tflapp.a in Frameworks */ = {isa = PBXBuildFile; fileRef = A103EB36E89F05E8B43D63BE /* libPods-tflapp.a */; };
                                        
                                    }
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let objects = config["objects"] as! XcodeDictionaryExpression
        print(objects.value)
//        let archiveVersion = config["archiveVersion"] as! XcodeSimpleExpression
//        let objectVersion = config["objectVersion"] as! XcodeSimpleExpression
//        XCTAssertEqual(archiveVersion, XcodeSimpleExpression(value: "1", comment: nil))
//        XCTAssertEqual(objectVersion, XcodeSimpleExpression(value: "46", comment: nil))
    }
    
//    func testThatItShouldReadTFLProjectFile() {
//        let url = Bundle(for: type(of:self)) .url(forResource: "tflproject", withExtension: "sample")
//        let project = try! String(contentsOf: url!)
//        let parser = try! XcodeConfigurationParser(configuration:project)
//        XCTAssertNoThrow(try parser.parse())
//    }
//
//    func testThatItShouldReadTFLProjectFileCorrectly() {
//        let url = Bundle(for: type(of:self)) .url(forResource: "tflproject", withExtension: "sample")
//        let project = try! String(contentsOf: url!)
//        let parser = try! XcodeConfigurationParser(configuration:project)
//        let dict = try! parser.parse()
//        let objects = dict["objects"]
//        print(objects)
//    }

}
