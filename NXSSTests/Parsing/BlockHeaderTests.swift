//
//  BlockHeaderTests.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/9/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation 

import XCTest
@testable import NXSS

class BlockHeaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMixin() {
        
        switch try! BlockHeader.parse("@mixin foo(a,b,3)") {
        case .Mixin(let sel, let args):
            XCTAssert(sel == "foo" , "Wrong selector")
            XCTAssert(args.count == 3 , "Wrong arg number")
            XCTAssert(args[0] == "a" , "Wrong arg")
            XCTAssert(args[1] == "b" , "Wrong arg")
            XCTAssert(args[2] == "3" , "Wrong arg")
            
        default:
            XCTAssert(false,"Expected a mixin")
        }
    }
    
    func testMixin2() {
        switch try! BlockHeader.parse("@mixin foo(a,bar(1,2),c)") {
        case .Mixin(let sel, let args):
            XCTAssert(sel == "foo" , "Wrong selector")
            XCTAssert(args.count == 3 , "Wrong arg number")
            XCTAssert(args[0] == "a" , "Wrong arg")
            XCTAssert(args[1] == "bar(1,2)" , "Wrong arg")
            XCTAssert(args[2] == "c" , "Wrong arg")
            
        default:
            XCTAssert(false,"Expected a mixin")
        }
    }
    
    func testElement() {

        switch try! BlockHeader.parse("foo") {
        case .Element(let sel, let pseudoClass):
            XCTAssert(sel == "foo" , "Wrong selector")
            XCTAssert(pseudoClass == .Normal , "Wrong pseudo class")
            
        default:
            XCTAssert(false,"Wrong type")
        }
    }

    func testElement2() {
        switch try! BlockHeader.parse("foo:selected") {
        case .Element(let sel, let pseudoClass):
            XCTAssert(sel == "foo" , "Wrong selector")
            XCTAssert(pseudoClass == .Selected  , "Wrong pseudo class")
            
        default:
            XCTAssert(false,"Wrong type")
        }
    }
    
    func testClass() {
        switch try! BlockHeader.parse(".foo:selected") {
        case .Class(let sel, let pseudoClass):
            XCTAssert(sel == "foo" , "Wrong selector")
            XCTAssert(pseudoClass == .Selected  , "Wrong pseudo class")
            
        default:
            XCTAssert(false,"Wrong type")
        }
    }
 
}