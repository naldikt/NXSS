//
//  Parser.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/22/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

class Parser {
    
    let fileName : String
    let bundle : NSBundle?
    
    /**
        - parameters:
            - fileName
            - bundle
    */
    init( fileName : String , bundle : NSBundle? = nil ) throws {
        self.fileName = fileName
        self.bundle = bundle
    }
    
	func parse() throws -> ParserResult {
        do {
            
            let fileEvaluator = FileEvaluator(fileName:fileName,bundle:bundle)
            let resultingScope = try fileEvaluator.eval( Scope(selector: nil, parentScope: nil) )
            let parserResult = ParserResult(ruleSets: resultingScope.compiledRuleSets , variables: resultingScope.getAllVariables())
            return parserResult
            
        } catch let error as NXSSError {
            
            switch error {
            case .Parse(let msg, let statement, let line):
                NSLog("---------------------------------")
                NSLog("[NXSS] Parsing error encountered in \(self.fileName): \(msg)")
                if let statement = statement { NSLog("At statement: \(statement)") }
                if let line = line { NSLog("At line: \(line)") }
                NSLog("---------------------------------")
            case .Require(let msg, let statement, let line):
                NSLog("---------------------------------")
                NSLog("[NXSS] Requirement error encountered in \(self.fileName): \(msg)")
                if let statement = statement { NSLog("At statement: \(statement)") }
                if let line = line { NSLog("At line: \(line)") }
                NSLog("---------------------------------")
            case .Logic(let msg, let statement, let line):
                NSLog("---------------------------------")
                NSLog("[NXSS] Logic error encountered in \(self.fileName): \(msg)")
                if let statement = statement { NSLog("At statement: \(statement)") }
                if let line = line { NSLog("At line: \(line)") }
                NSLog("---------------------------------")
            }
            throw error
            
        } catch let error {
            
            NSLog("[ERROR] Unknown: \(error)")
            throw error
        }

	}

    
    
    
}