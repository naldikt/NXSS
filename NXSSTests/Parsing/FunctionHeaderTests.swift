//
//  BlockHeaderTests.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/6/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

import XCTest
@testable import NXSS

class FunctionHeaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSimple() {
        let (name,args) = try! FunctionHeader.parse("foo(1,2,3)")
        XCTAssert(name == "foo" , "Wrong func name parsing")
        XCTAssert(args.count == 3)
        XCTAssert(args[0] == "1")
        XCTAssert(args[1] == "2")
        XCTAssert(args[2] == "3")
    }
    
    func testNoArgs() {
        let (name,args) = try! FunctionHeader.parse("foo()")
        XCTAssert(name == "foo" , "Wrong func name parsing")
        XCTAssert(args.count == 0)
    }
    
    func testComplex() {
        let (name,args) = try! FunctionHeader.parse("foo(1,bar(a,b),3)")
        XCTAssert(name == "foo" , "Wrong func name parsing")
        XCTAssert(args.count == 3)
        XCTAssert(args[0] == "1")
        XCTAssert(args[1] == "bar(a,b)")
        XCTAssert(args[2] == "3")
    }
    
    func testComplex2() {
        let (name,args) = try! FunctionHeader.parse("foo(1,bar(a,zee(10,11),c),3)")
        XCTAssert(name == "foo" , "Wrong func name parsing")
        XCTAssert(args.count == 3)
        XCTAssert(args[0] == "1")
        XCTAssert(args[1] == "bar(a,zee(10,11),c)")
        XCTAssert(args[2] == "3")
    }
    
    func testComplexNoArg() {
        let (name,args) = try! FunctionHeader.parse("foo(1,bar(),3)")
        XCTAssert(name == "foo" , "Wrong func name parsing")
        XCTAssert(args.count == 3)
        XCTAssert(args[0] == "1")
        XCTAssert(args[1] == "bar()")
        XCTAssert(args[2] == "3")
    }
}