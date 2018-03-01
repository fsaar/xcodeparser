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
        let config = try! parser.parse()
        XCTAssert(config.keys.isEmpty)
    }

    func testThatItShouldReadAKeyValueConfiguration() {
        let configString =  """
                                {
                                    key = value;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let key = config.keys.first!
        let value = config.values.first!.string
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
        let config = try! parser.parse()
        let key = config.keys.first!
        let value = config.values.first!.string
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
        let config = try! parser.parse()
        let key = config.keys.first!
        let value = config.values.first!.string
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
        let dict = config["classes"]!.dict!
        XCTAssertEqual(key,"classes")
        XCTAssert(dict.isEmpty)
       
    }

    func testThatItShouldReadAKeyValueConfigurationWithAComment() {
        let configString =  """
                               
                                {
                                /* Begin PBXAggregateTarget section */
                                     classes = {};
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let key = config.keys.first!
        let dict = config["classes"]!.dict!
        XCTAssertEqual(key,"classes")
        XCTAssert(dict.isEmpty)
        
    }

    func testThatItShouldReadAKeyValueConfigurationWithMultipleEntries() {
        let configString =  """
                                {
                                    key1 = value1;
                                    key2 = value2;
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let value = config["key1"]!.string!
        let value2 = config["key2"]!.string!
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
        let config = try! parser.parse()
        let value = config["key1"]!.string!
        let value2 = config["key2"]!.string!
        let value3 = config["key3"]!.string!
        let expression = config["key4"]!.value as! XcodeSimpleExpression
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(value2,"value2")
        XCTAssertEqual(value3,"value3")
        XCTAssertEqual(expression,XcodeSimpleExpression(value:"value4",comment:" comment_ 4 "))
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
        let value = config["OBJ_10"]!.string!
        let comment = (config["OBJ_11"]!.value as! XcodeListExpression).comment
        let valueList = config["OBJ_11"]!.stringList!
        XCTAssertEqual(value,"value1")
        XCTAssertEqual(comment," List ")
        XCTAssertEqual(valueList,["value2","value3"])
    }

    func testThatItShouldParseValueWithCommentCorrectly() {
        let configString =  """
                                {
                                    buildConfigurationList = OBJ_50 /* Build configuration list for PBXAggregateTarget "xcodeparserPackageTests" */;
                                    name = xcodeparserPackageTests;
                                    productName = xcodeparserPackageTests;
                                };
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let value1 = config["buildConfigurationList"]!.string!
        let value2 = config["name"]!.string!
        let value3 = config["productName"]!.string!
        XCTAssertEqual(value1,"OBJ_50")
        XCTAssertEqual(value2,"xcodeparserPackageTests")
        XCTAssertEqual(value3,"xcodeparserPackageTests")
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
        let valueList = config["OBJ_10"]!.stringList!
        XCTAssertEqual(valueList,["\"$(inherited)\"","\"inherited2\"","inherited3"])
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
        let value = config["key1"]!.string
         let expression = config["children"]!.value as! XcodeListExpression
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
        let expression = config["OBJ_40"]!.value as! XcodeDictionaryExpression
        let comment1 = expression.comment
        let dict = expression.value
        let value1 = dict["isa"]!.string
        let value2 = dict["buildActionMask"]!.string
        let value3 = dict["runOnlyForDeploymentPostprocessing"]!.string
        XCTAssertEqual(value1,"PBXFrameworksBuildPhase")
        XCTAssertEqual(comment1," Frameworks ")
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
        let expression = config["OBJ_44"]!.value as! XcodeDictionaryExpression
        let obj_44 = expression.value
        let comment1 = expression.comment
        let buildSettings = obj_44["buildSettings"]!.value as! XcodeDictionaryExpression
        let testability = buildSettings.value["ENABLE_TESTABILITY"]!.string!
        let searchPaths = buildSettings.value["FRAMEWORK_SEARCH_PATHS"]!.stringList
        XCTAssertEqual(comment1," Debug ")
        XCTAssertEqual(testability,"YES")
        XCTAssertEqual(searchPaths, ["\"$(inherited)\"",
                               "\"$(PLATFORM_DIR)/Developer/Library/Frameworks\""])
    }

    func testThatItShouldRealConfigurationExampleCorrectly() {
        let configString = """
                                // !$*UTF8*$!
                                {
                                        archiveVersion = 1;
                                        classes = {
                                        };
                                        objectVersion = 46;
                                        objects = {

                                /* Begin PBXAggregateTarget section */
                                                "xcodeparser::xcodeparserPackageTests::ProductTarget" /* xcodeparserPackageTests */ = {
                                                        isa = PBXAggregateTarget;
                                                        buildConfigurationList = OBJ_50 /* Build configuration list for PBXAggregateTarget "xcodeparserPackageTests" */;
                                                        buildPhases = (
                                                        );
                                                        dependencies = (
                                                                OBJ_53 /* PBXTargetDependency */,
                                                        );
                                                        name = xcodeparserPackageTests;
                                                        productName = xcodeparserPackageTests;
                                                };
                                /* End PBXAggregateTarget section */

                                /* Begin PBXBuildFile section */
                                                560024B02025F23F00104EF3 /* String + Extension.swift in Sources */ = {isa = PBXBuildFile; fileRef = 560024AE2025F22700104EF3 /* String + Extension.swift */; };
                                                5616B5A3202C92E7009AC676 /* XcodeExpression.swift in Sources */ = {isa = PBXBuildFile; fileRef = 5616B5A1202C92CC009AC676 /* XcodeExpression.swift */; };
                                                56547EE0201F615B00F52AF3 /* ExpressionExtractor.swift in Sources */ = {isa = PBXBuildFile; fileRef = 56547EDE201F5A7B00F52AF3 /* ExpressionExtractor.swift */; };
                                                56547EE2201F646200F52AF3 /* ExpressionStack.swift in Sources */ = {isa = PBXBuildFile; fileRef = 56547EE1201F646200F52AF3 /* ExpressionStack.swift */; };
                                                56547EE4201F724600F52AF3 /* ExpressionStackTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = 56547EE3201F724600F52AF3 /* ExpressionStackTests.swift */; }
                                            
                                        }
                                }
                            """
        let parser = try! XcodeConfigurationParser(configuration:configString)
        let config = try! parser.parse()
        let objects = config["objects"]!.dict!
        XCTAssertEqual(objects.keys.count,6)
        print(objects.keys)
        let target = objects["\"xcodeparser::xcodeparserPackageTests::ProductTarget\""]!.dict!
        XCTAssertEqual(target.keys.count,6)
        XCTAssertNotNil(objects["560024B02025F23F00104EF3"])
        XCTAssertNotNil(objects["5616B5A3202C92E7009AC676"])
        XCTAssertNotNil(objects["56547EE0201F615B00F52AF3"])
        XCTAssertNotNil(objects["56547EE2201F646200F52AF3"])
        XCTAssertNotNil(objects["56547EE4201F724600F52AF3"])
    }

    func testThatItShouldReadTFLProjectFileCorrectly() {
        let url = Bundle(for: type(of:self)) .url(forResource: "tflproject", withExtension: "sample")
        let project = try! String(contentsOf: url!)
        let parser = try! XcodeConfigurationParser(configuration:project)
        let dict = try! parser.parse()
        let objects = dict["objects"]!.dict!
        XCTAssertEqual(objects.keys.count,179)
        XCTAssertNotNil(objects["564EC6F21DDFE205008CFD11"])
        XCTAssertNotNil(objects["566EF7D51DDC4D14006162D7"])
        XCTAssertNotNil(objects["5657D36F1DE387E6004E4CD0"])
        XCTAssertNotNil(objects["564EC7041DE1917D008CFD11"])
        XCTAssertNotNil(objects["566EF7C31DDA2D31006162D7"])
        XCTAssertNotNil(objects["565A1FCD1DD8F93F003CE960"])
        XCTAssertNotNil(objects["564EC6F11DDFE180008CFD11"])
        XCTAssertNotNil(objects["BEB656AE4FFADE13DD37A13F"])
        XCTAssertNotNil(objects["565A1FC91DD8F8D1003CE960"])
        XCTAssertNotNil(objects["56A81B3E1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["566EF7E11DDC59ED006162D7"])
        XCTAssertNotNil(objects["566EF7E21DDC59ED006162D7"])
        XCTAssertNotNil(objects["5646C4031DE62389006EA956"])
        XCTAssertNotNil(objects["565A1FC51DD8F331003CE960"])
        XCTAssertNotNil(objects["565A1FC81DD8F6E6003CE960"])
        XCTAssertNotNil(objects["564EC7071DE1917D008CFD11"])
        XCTAssertNotNil(objects["566EF7D71DDC4D14006162D7"])
        XCTAssertNotNil(objects["561FD9021F1FB1F50012466A"])
        XCTAssertNotNil(objects["566EF7C71DDA3A2B006162D7"])
        XCTAssertNotNil(objects["564EC7051DE1917D008CFD11"])
        XCTAssertNotNil(objects["564EC6F81DE0DC1C008CFD11"])
        XCTAssertNotNil(objects["566EF7E31DDC5D69006162D7"])
        XCTAssertNotNil(objects["56823EAB1DDDA54100E79B1A"])
        XCTAssertNotNil(objects["5646C4021DE62389006EA956"])
        XCTAssertNotNil(objects["5685ADC31DEF8DDC009FD6A5"])
        XCTAssertNotNil(objects["56C8288F1DE8E9FA00E52086"])
        XCTAssertNotNil(objects["FE001E57A0E40DC9805C38C7"])
        XCTAssertNotNil(objects["56C828951DEA396400E52086"])
        XCTAssertNotNil(objects["564EC7001DE1917D008CFD11"])
        XCTAssertNotNil(objects["56A81B2D1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["4B310D95D34D5BED18455079"])
        XCTAssertNotNil(objects["565A1FC11DD8F317003CE960"])
        XCTAssertNotNil(objects["56823EA61DDDA39600E79B1A"])
        XCTAssertNotNil(objects["56C828961DEA396400E52086"])
        XCTAssertNotNil(objects["561FD9011F1FADD30012466A"])
        XCTAssertNotNil(objects["B6405A0BEDCDF1FE409534F9"])
        XCTAssertNotNil(objects["AC828CD492670DF6F91697A8"])
        XCTAssertNotNil(objects["564EC7061DE1917D008CFD11"])
        XCTAssertNotNil(objects["5641F6EE1F19F68B00A3A9D2"])
        XCTAssertNotNil(objects["566EF7D21DDB71CE006162D7"])
        XCTAssertNotNil(objects["564EC6FE1DE1917D008CFD11"])
        XCTAssertNotNil(objects["562DBF5A1E05B6780028F3CD"])
        XCTAssertNotNil(objects["566EF7D11DDB5685006162D7"])
        XCTAssertNotNil(objects["5657D36B1DE387E6004E4CD0"])
        XCTAssertNotNil(objects["56823EAD1DDDA5B300E79B1A"])
        XCTAssertNotNil(objects["56C6A3461DF44F6A00067D06"])
        XCTAssertNotNil(objects["5692B5001DF2E26300C56A3C"])
        XCTAssertNotNil(objects["566EF7D41DDC4D14006162D7"])
        XCTAssertNotNil(objects["5657D36E1DE387E6004E4CD0"])
        XCTAssertNotNil(objects["565A1FC31DD8F317003CE960"])
        XCTAssertNotNil(objects["56C2D6DC1DE5D6B000F43628"])
        XCTAssertNotNil(objects["564EC6FC1DE10272008CFD11"])
        XCTAssertNotNil(objects["5657D36A1DE387E6004E4CD0"])
        XCTAssertNotNil(objects["564EC6FB1DE0DC1C008CFD11"])
        XCTAssertNotNil(objects["564EC7021DE1917D008CFD11"])
        XCTAssertNotNil(objects["5657D3701DE38ADF004E4CD0"])
        XCTAssertNotNil(objects["565A1FCE1DD8F93F003CE960"])
        XCTAssertNotNil(objects["56A81B2B1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56A81B261DD862DC001DF7F1"])
        XCTAssertNotNil(objects["566EF7D31DDB71CE006162D7"])
        XCTAssertNotNil(objects["56D70D341DD9A7A6004CA293"])
        XCTAssertNotNil(objects["5692B4FF1DF2E26300C56A3C"])
        XCTAssertNotNil(objects["564EC6F41DE0A2A0008CFD11"])
        XCTAssertNotNil(objects["566EF7D61DDC4D14006162D7"])
        XCTAssertNotNil(objects["56B86EAD1DE4FED000A89D16"])
        XCTAssertNotNil(objects["56A81B381DD862DC001DF7F1"])
        XCTAssertNotNil(objects["5657D3631DE387E6004E4CD0"])
        XCTAssertNotNil(objects["56D0AF311E141D0F00F466C4"])
        XCTAssertNotNil(objects["5657D36C1DE387E6004E4CD0"])
        XCTAssertNotNil(objects["56823EAE1DDDA5B300E79B1A"])
        XCTAssertNotNil(objects["56B86EAC1DE4FED000A89D16"])
        XCTAssertNotNil(objects["56A81B331DD862DC001DF7F1"])
        XCTAssertNotNil(objects["564EC6F71DE0DC0E008CFD11"])
        XCTAssertNotNil(objects["5657D3661DE387E6004E4CD0"])
        XCTAssertNotNil(objects["5657D3731DE3A00A004E4CD0"])
        XCTAssertNotNil(objects["56A81B391DD862DC001DF7F1"])
        XCTAssertNotNil(objects["565A1FD11DD8FB2A003CE960"])
        XCTAssertNotNil(objects["5657D3741DE3B480004E4CD0"])
        XCTAssertNotNil(objects["56C828941DE9CDB900E52086"])
        XCTAssertNotNil(objects["56D0AF321E141D2C00F466C4"])
        XCTAssertNotNil(objects["5685ADC41DEF8DDC009FD6A5"])
        XCTAssertNotNil(objects["562DBF591E05B6780028F3CD"])
        XCTAssertNotNil(objects["566EF7E01DDC59D9006162D7"])
        XCTAssertNotNil(objects["CA12D93F7484B0C6E06F9920"])
        XCTAssertNotNil(objects["564EC6FF1DE1917D008CFD11"])
        XCTAssertNotNil(objects["5CCA668F6EB7B436258B28AA"])
        XCTAssertNotNil(objects["56D70D301DD9A7A6004CA293"])
        XCTAssertNotNil(objects["56A81B3F1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["566EF7CD1DDB0851006162D7"])
        XCTAssertNotNil(objects["564EC6FD1DE10272008CFD11"])
        XCTAssertNotNil(objects["56823EA91DDDA4CC00E79B1A"])
        XCTAssertNotNil(objects["56A81B231DD862DC001DF7F1"])
        XCTAssertNotNil(objects["5657D3721DE3A00A004E4CD0"])
        XCTAssertNotNil(objects["564EC70A1DE1917D008CFD11"])
        XCTAssertNotNil(objects["56A81B3A1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["5657D3751DE3B480004E4CD0"])
        XCTAssertNotNil(objects["56823EAC1DDDA54100E79B1A"])
        XCTAssertNotNil(objects["566EF7CB1DDB0851006162D7"])
        XCTAssertNotNil(objects["09B8C602EFB434FF269AB5A9"])
        XCTAssertNotNil(objects["564EC6F91DE0DC1C008CFD11"])
        XCTAssertNotNil(objects["56A81B281DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56A81B411DD862DC001DF7F1"])
        XCTAssertNotNil(objects["B5ACE26E6374F6550AC45E8A"])
        XCTAssertNotNil(objects["56A81B401DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56D70D331DD9A7A6004CA293"])
        XCTAssertNotNil(objects["7A89F45A39DFA1D633B11475"])
        XCTAssertNotNil(objects["56A81B3C1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["412222F26B670B4DE4DA2909"])
        XCTAssertNotNil(objects["56823EAA1DDDA4CC00E79B1A"])
        XCTAssertNotNil(objects["566EF7CA1DDB0851006162D7"])
        XCTAssertNotNil(objects["565A1FC21DD8F317003CE960"])
        XCTAssertNotNil(objects["56823EA71DDDA45600E79B1A"])
        XCTAssertNotNil(objects["564EC6F31DE0A289008CFD11"])
        XCTAssertNotNil(objects["564EC7081DE1917D008CFD11"])
        XCTAssertNotNil(objects["5692B5021DF2E4EB00C56A3C"])
        XCTAssertNotNil(objects["E665C226CB022DA33D91ED39"])
        XCTAssertNotNil(objects["5657D3641DE387E6004E4CD0"])
        XCTAssertNotNil(objects["5657D3621DE387E6004E4CD0"])
        XCTAssertNotNil(objects["5657D36D1DE387E6004E4CD0"])
        XCTAssertNotNil(objects["56A81B421DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56A81B341DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56D0AF331E141D2C00F466C4"])
        XCTAssertNotNil(objects["56A81B2A1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56A81B221DD862DC001DF7F1"])
        XCTAssertNotNil(objects["565A1FC71DD8F6E6003CE960"])
        XCTAssertNotNil(objects["564EC6FA1DE0DC1C008CFD11"])
        XCTAssertNotNil(objects["56823EA81DDDA45600E79B1A"])
        XCTAssertNotNil(objects["2C659326B6D6A9829EDDAFC3"])
        XCTAssertNotNil(objects["56AB9FAC1DE8D95A00A9042A"])
        XCTAssertNotNil(objects["56D70D311DD9A7A6004CA293"])
        XCTAssertNotNil(objects["A103EB36E89F05E8B43D63BE"])
        XCTAssertNotNil(objects["5657D3711DE38ADF004E4CD0"])
        XCTAssertNotNil(objects["564EC6F61DE0DA8D008CFD11"])
        XCTAssertNotNil(objects["565A1FD01DD8FB2A003CE960"])
        XCTAssertNotNil(objects["566EF7C61DDA3A2B006162D7"])
        XCTAssertNotNil(objects["5692B5061DF2F15F00C56A3C"])
        XCTAssertNotNil(objects["564EC6F51DE0A2A0008CFD11"])
        XCTAssertNotNil(objects["56823EA51DDDA39600E79B1A"])
        XCTAssertNotNil(objects["56D70D321DD9A7A6004CA293"])
        XCTAssertNotNil(objects["5692B5071DF2F15F00C56A3C"])
        XCTAssertNotNil(objects["56C828911DE9859D00E52086"])
        XCTAssertNotNil(objects["5657D3651DE387E6004E4CD0"])
        XCTAssertNotNil(objects["565A1FD21DD8FB2A003CE960"])
        XCTAssertNotNil(objects["56D70D131DD9A25F004CA293"])
        XCTAssertNotNil(objects["56A81B3D1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56A81B321DD862DC001DF7F1"])
        XCTAssertNotNil(objects["565A1FC61DD8F6D9003CE960"])
        XCTAssertNotNil(objects["5657D3671DE387E6004E4CD0"])
        XCTAssertNotNil(objects["564EC6EF1DDFAA67008CFD11"])
        XCTAssertNotNil(objects["56D70D351DD9A7A6004CA293"])
        XCTAssertNotNil(objects["56A81B2C1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["5692B4FE1DF2E21100C56A3C"])
        XCTAssertNotNil(objects["56D70D121DD9A24E004CA293"])
        XCTAssertNotNil(objects["5692B5031DF2E4EB00C56A3C"])
        XCTAssertNotNil(objects["56C828921DE9859D00E52086"])
        XCTAssertNotNil(objects["56A81B2F1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56D0AF351E147C6F00F466C4"])
        XCTAssertNotNil(objects["565A1FCF1DD8F93F003CE960"])
        XCTAssertNotNil(objects["56C6A3471DF44F6A00067D06"])
        XCTAssertNotNil(objects["29D20D8BDB3378F1D7CC9DAE"])
        XCTAssertNotNil(objects["5641F6ED1F19F68100A3A9D2"])
        XCTAssertNotNil(objects["564EC7011DE1917D008CFD11"])
        XCTAssertNotNil(objects["564EC7031DE1917D008CFD11"])
        XCTAssertNotNil(objects["56D0AF341E147C6F00F466C4"])
        XCTAssertNotNil(objects["56A81B2E1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56AB9FAB1DE8D95A00A9042A"])
        XCTAssertNotNil(objects["56A81B291DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56C828931DE9CDB900E52086"])
        XCTAssertNotNil(objects["56AB9FA91DE8D94000A9042A"])
        XCTAssertNotNil(objects["566EF7CC1DDB0851006162D7"])
        XCTAssertNotNil(objects["56D70D141DD9A25F004CA293"])
        XCTAssertNotNil(objects["566EF7D01DDB5679006162D7"])
        XCTAssertNotNil(objects["56C828901DE8E9FA00E52086"])
        XCTAssertNotNil(objects["56A81B271DD862DC001DF7F1"])
        XCTAssertNotNil(objects["56A81B3B1DD862DC001DF7F1"])
        XCTAssertNotNil(objects["5692B5011DF2E4C200C56A3C"])
        XCTAssertNotNil(objects["565A1FC41DD8F331003CE960"])
        XCTAssertNotNil(objects["56D70D2F1DD9A7A6004CA293"])
        XCTAssertNotNil(objects["E391093442B4E54575D4146B"])
    }
    
    func testThatItShouldReadTFLProjectFileCorrectly2() {
        let url = Bundle(for: type(of:self)) .url(forResource: "aimia", withExtension: "sample")
        let project = try! String(contentsOf: url!)
        let parser = try! XcodeConfigurationParser(configuration:project)
        let dict = try! parser.parse()
        let objects = dict["objects"]!.dict!
        XCTAssertEqual(objects.keys.count,1949)
    }
}
