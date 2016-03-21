//
//  SuccessfulTests.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/3/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

import XCTest
@testable import NXSS

class SuccessfulTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        

    }
    
    override func tearDown() {
        super.tearDown()
    
    }
    
    private func test( inputFileName : String , outputDict : [String:[String:String]] ) {
        
        NXSS.sharedInstance.useFile(inputFileName, bundle: NSBundle(forClass: self.dynamicType ))
        
        if let res = try? NXSS.sharedInstance.isEqualRuleSets( outputDict) {
//            print(NXSS.sharedInstance.ruleSets)
            XCTAssert( res )
        }
        

        
    }
    
    
    
    func testBasic() {
        test("parsing_basic.nxss",
            outputDict: [
                "BlueButton" : [
                    "font-name" : "blue"
                ],
                ".BlueCircleButton" : [
                    "font-name" : "blue",
                    "corner-radius" : "circle"
                ]
            ])
    }


    
    func testInclude() {
        test("parsing_include.nxss",
            outputDict: [
                "BlueCircleButton" : [
                    "background-color" : "white",
                    "font-color":"blue",
                    "font-size":"5",
                    "corner-radius":"circle"
                ]
            ])
    }

  
    
    func testExtend() {
        test("parsing_extend.nxss",
            outputDict: [
                ".BaseClass": [
                    "background-color":"red",
                    "font-color":"red",
                    "border-color":"red"
                ],
                ".ChildClass" : [
                    "background-color":"red",
                    "font-color":"red",
                    "border-color":"red",
                    "corner-radius":"1"
                ],
                "UILabel":[
                    "background-color":"blue",
                    "font-color":"red",
                    "border-color":"red"
                ],
                "MixedGrandChildElement":[
                    "font-size": "9",
                    "font-name" : "NapsterXFont",
                    "background-color":"red",
                    "font-color":"red",
                    "border-color":"green",
                    "corner-radius":"1"
                ]
            ]
        )
    }

  
    func testVariables() {
        test("parsing_variables.nxss",
            outputDict: [
                "BlueButton" : [
                    "font-size":"5",
                    "corner-radius":"circle"
                ],
                "CircleButton" : [
                    "background-color":"white",
                    "font-name" :"font"
                ]
            ])
    }

    func testComplex() {
        // This will also test Multiple Overrides
        test("parsing_complex.nxss",
            outputDict: [
                "PrimaryButton" : [
                    "corner-radius":"circle",
                    "background-color":"white",
                    "border-width":"5"
                ],
                "SecondaryButton" : [
                    "font-color":"black",
                    "corner-radius":"circle",
                    "background-color" :"red"
                ]
            ])
    }
    
    func testSelector() {
        test("parsing_selector.nxss",
            outputDict: [
                "Button:normal" : [
                    "background-color":"red",
                    "type":"normal"
                ],
                "Button:selected" : [
                    "background-color":"red",
                    "type":"selected"
                ],
                "Button:highlighted" : [
                    "background-color":"red",
                    "type":"highlighted"
                ],
                "Button:disabled" : [
                    "background-color":"red",
                    "type":"disabled"
                ],
                "Label:normal" : [
                    "background-color":"black",
                    "type":"normal"
                ],
                "Label:selected" : [
                    "background-color":"black",
                    "type":"selected"
                ]
            ])
    }

    
    func testImport() {
        test("parsing_import.nxss",
            outputDict: [
                "BlueButton:normal" : [
                    "corner-radius":"circle",
                    "background-color":"blue"
                ],
                ".BlueCloneButton:normal" : [
                    "corner-radius":"circle",
                    "background-color":"blue"
                ],
                "NaldiButton:normal" : [
                    "background-color":"naldi"
                ],
                "NaldiCloneButton:normal" : [
                    "background-color":"naldi"
                ],
                "AndrewButton:normal" : [
                    "background-color":"andrew"
                ],
                "RichButton:normal":[
                    "background-color":"rich"
                ]
            ])
    }
    
    
}