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
    
    /**
        - parameters:
            - fileName
            - bundle    
            - parserResult     Optional. This is passed during "@import" operation so this parser can use the knowledge from another parser.

    */
    init( fileName : String , bundle : NSBundle? = nil , parserResult : ParserResult? = nil ) throws {
        
        self.fileName = fileName
        self.fileBundle = bundle
        
        if let parserResult = parserResult {
            self.parserResult = NXSSParserResult(parserResult:parserResult)  // Use parent's if available.
        }

        guard let filePath = Parser.pathForFile(fileName, bundle:bundle) else {
            self.fileContent = ""
            throw NXSSError.Require(msg: "FilePath does not exist", statement: fileName, line: nil)
        }
        guard let data = NSData(contentsOfFile:filePath) else {
            self.fileContent = ""
            throw NXSSError.Require(msg: "Data from path is invalid", statement: filePath, line: nil)
        }
        guard let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String else {
            self.fileContent = ""
            throw NXSSError.Require(msg: "Data cannot be converted to String", statement: "<cannot print data>", line: nil)
        }
        
        self.fileContent = dataString
        

    }
    

	/**
		Parses the input string.
		:return:	The ruleSet.
				String => Name of the style class.
				StyleClass => Parsed, compiled entries.
	*/
	func parse() throws -> ParserResult {
        do {
            
            try traverse()
            return self.parserResult
            
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
            }
            throw error
            
        } catch let error {
            
            NSLog("[ERROR] Unknown: \(error)")
            throw error
        }

	}

    
    // MARK: - Private
    
    private var blockQueue : Queue<Block> = Queue()
    
    private var parserResult : NXSSParserResult = NXSSParserResult()
    
    private let fileContent : String
    
    private let fileBundle : NSBundle?
    
    private static let fileExtension = ".nxss"
    
    /**
    Return the path for the fileName.
    - parameters:
    - fileName      The fileName of NXSS style file. You do not need to pass the ".nxss" extension to this fileName.
    - bundle        The bundle of where the file is located.
    Default bundle (nil) implies mainBundle.
    If it's in another bundle (i.e. you're running this from unit testing), then please pass the bundle.
    */
    private class func pathForFile(fileName : String , bundle : NSBundle? = nil) -> FilePath? {
        
        var fileNameToLookUp = fileName
        if fileNameToLookUp.hasSuffix(self.fileExtension) {
            fileNameToLookUp.removeRange(
                Range(
                    start: fileNameToLookUp.endIndex.advancedBy(-self.fileExtension.characters.count),
                    end: fileNameToLookUp.endIndex
                )
            )
        }
        
        var path : String?
        
        if let bundle = bundle {
            path = bundle.pathForResource(fileNameToLookUp, ofType: self.fileExtension)
        } else {
            path = NSBundle.mainBundle().pathForResource(fileNameToLookUp, ofType: self.fileExtension)
        }
        
        return path
    }
    
    // MARK: - State Machine
    
    
    private func traverse() throws {

        var curLineNum = 1  // line num starts from 1-based
        var curLine : String.CharacterView = String.CharacterView()
        curLine.reserveCapacity(100)
        
        var commandParser = CommandParser()
        
        // Push MainBlock
        let mainBlock = Block(selector: nil, parentBlock: nil)
        mainBlock.addDeclarations(self.parserResult.variables)
        blockQueue.push(mainBlock)
        
        let chars = self.fileContent.characters
        for c : Character in chars {
            
            // Debugging purpose. Keep track of the lines.
            curLine.append(c)
            if c == "\n" {
                curLineNum++
                curLine.removeAll()
            }
            
            guard let curBlock = blockQueue.peek() else {
                throw NXSSError.Require(msg: "BlockQueue.peek() just failed", statement: "", line: nil)
            }
            
            // Run the Parser.
            if let resultType : CPResultType = commandParser.append(c) {
                switch resultType {
                    
                    // MARK: InProgress
                case .InProgress: continue    // Nothign todo.
                    
                    // MARK: Extend
                case .Extend(let selector, let selectorType, let pseudoClass):
                    let compiledKey = CompiledRuleSet.getCompiledKey(selector,selectorType: selectorType, pseudoClass: pseudoClass)
                    
                    guard let baseStyle = parserResult.ruleSets[compiledKey] else {
                        throw NXSSError.Require(msg: "Cannot find class/element to extend from with name \"\(selector)\"", statement: String(curLine), line:curLineNum)
                    }
                    
                    curBlock.addDeclarations(baseStyle.declarations)
                    
                    
                    // MARK: Include
                case .Include(let selector, let argumentValues):
                    
                    guard let mixin = parserResult.mixins[selector] else {
                        throw NXSSError.Require(msg: "Cannot find mixin named \(selector)", statement: String(curLine), line:curLineNum)
                    }
                    
                    curBlock.addDeclarations(
                        try mixin.resolveArguments(argumentValues)
                    )
                    
                    // MARK: Import
                case .Import(let fileName):
                    // Let's start a new parser (recursive)
                    self.parserResult.addVariables(blockQueue.peek()!.getAllVariables())
                    let parser = try Parser(fileName: fileName, bundle: fileBundle , parserResult: self.parserResult)
                    let parserResult = try parser.parse()
                    self.parserResult.mergeFrom(parserResult)
                    blockQueue.peek()!.addDeclarations(parserResult.variables)

                    
                    // MARK: StyleDeclaration
                case .StyleDeclaration(let key, let value):
                    curBlock.addDeclaration(key,value:value)
                    
                    // MARK: RuleSetHeader
                case .RuleSetHeader(let selector, let selectorType, let pseudoClass):
                    blockQueue.push(
                        RuleSetBlock(selector:selector,
                                selectorType: selectorType,
                                pseudoClass: pseudoClass,
                                parentBlock:blockQueue.peek())
                    )
                 
                    // MARK: MixinHeader
                case .MixinHeader(let selector, let argumentNames):
                    blockQueue.push(
                        MixinBlock(selector:selector,
                                    argNames:argumentNames,
                                parentBlock:blockQueue.peek())
                    )
                    
                    // MARK: BlockClosure
                case .BlockClosure:
                    
                    let oldContext = blockQueue.pop()
                    if let oldContext = oldContext as? MixinBlock {
                        
                        let styleMixin : CompiledMixin = try oldContext.compile()
                        self.parserResult.addMixin(styleMixin)
                        
                        
                    } else if let oldContext = oldContext as? RuleSetBlock {
                        
                        let styleClass : CompiledRuleSet = try oldContext.compile()
                        self.parserResult.addRuleSet(styleClass)
                        
                    } else {
                        throw NXSSError.Parse(msg: "Too many close bracket.", statement: String(curLine), line: curLineNum)
                        
                    }
                }
                

                commandParser = CommandParser(pastResult: resultType)
                
            } else {
                // CommandParser doesn't have any idea what this line is.
                NXSSError.Parse(msg: "Cannot parse line", statement: String(curLine), line: curLineNum)
            }
        } // end for loop
        
        let block = blockQueue.pop()
        assert( block === mainBlock , "There is something wrong. This popped block should've been the main block" )
        self.parserResult.addVariables(mainBlock.getAllVariables())
        

    } // end method
}