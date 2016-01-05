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
            - parentParser     Used internally during "import" to keep track of existing context and ruleSets.

    */
    init( fileName : String , bundle : NSBundle? = nil , parentParser : Parser? = nil ) throws {
        
        self.fileName = fileName
        self.fileBundle = bundle
        
        // TODO: at some point needs to refine these.
        guard let filePath = Parser.pathForFile(fileName, bundle:bundle) else {
            self.blockQueue = Queue()
            self.ruleSets = Dictionary()
            self.mixins = Dictionary()
            self.fileContent = ""
            throw NXSSError.Require(msg: "FilePath does not exist", statement: fileName, line: nil)
        }
        guard let data = NSData(contentsOfFile:filePath) else {
            self.blockQueue = Queue()
            self.ruleSets = Dictionary()
            self.mixins = Dictionary()
            self.fileContent = ""
            throw NXSSError.Require(msg: "Data from path is invalid", statement: filePath, line: nil)
        }
        guard let dataString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String else {
            self.blockQueue = Queue()
            self.ruleSets = Dictionary()
            self.mixins = Dictionary()
            self.fileContent = ""
            throw NXSSError.Require(msg: "Data cannot be converted to String", statement: "<cannot print data>", line: nil)
        }
        
        self.fileContent = dataString
        
        if let blockQueue = parentParser?.blockQueue {
            self.blockQueue = blockQueue
        } else {
            // If it's not passed, create a new one.
            self.blockQueue = Queue()
            self.blockQueue.push(Block())
        }
        
        if let ruleSets = parentParser?.ruleSets {
            self.ruleSets = ruleSets
        } else {
            // If it's not passed, create a new one.
            self.ruleSets = Dictionary()
        }
        
        if let mixins = parentParser?.mixins {
            self.mixins = mixins
        } else {
            // If it's not passed, create a new one
            self.mixins = Dictionary()
        }
    }
    

	/**
		Parses the input string.
		:return:	The ruleSet.
				String => Name of the style class.
				StyleClass => Parsed, compiled entries.
	*/
	func parse() throws -> [String:CompiledRuleSet] {
        do {
            
            try traverse()
            return self.ruleSets
            
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
    
    private var blockQueue : Queue<Block>
    
    private var ruleSets : [String:CompiledRuleSet]
    
    private let fileContent : String
    
    private let fileBundle : NSBundle?
    
    private var mixins : [String:CompiledMixin] // mixinName => StyleMixin
    
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
    
    
    private func traverse() throws -> [String:CompiledRuleSet] {

        var curBuffer : String.CharacterView = String.CharacterView()
        curBuffer.reserveCapacity(300)
        
        var skip = false
        var lastS:Character?
        var curLineNum = 1  // line num starts from 1-based
        
        let chars = self.fileContent.characters
        for s : Character in chars {
            
//            NSLog("CurBuf \(String(curBuffer))")
            
            if skip {
                
                // Check for Close comment
                if let lastS = lastS where s == "/" && "\(lastS)" == "*" {
                    skip = false
                }
                continue
                
            } else if s == " " {
                
                // We don't need empty spaces.
                continue
                
            } else if s == "\n" {
                
                curLineNum++
                continue
                
            }

            // Start of Context
            if s == "{" {
                
            
                // Figure out whether what kind of header this is
                let blockHeader = try BlockHeader.parse(String(curBuffer))
                switch blockHeader {

                case .Mixin(let selector, let args):

                    blockQueue.push(
                        MixinBlock(selector:selector,argNames:args,parentBlock:blockQueue.peek())
                    )

                case .Class(let selector,let pseudoClass):

                    blockQueue.push(
                        RuleSetBlock(selector:selector,selectorType:.Class, pseudoClass: pseudoClass,parentBlock:blockQueue.peek())
                    )
                    
                case .Element(let selector,let pseudoClass):

                    blockQueue.push(
                        RuleSetBlock(selector:selector,selectorType:.Element, pseudoClass: pseudoClass,parentBlock:blockQueue.peek())
                    )
                }
            
                curBuffer.removeAll(keepCapacity: true)
                                
                
            // End of Context
            } else if s == "}" {
                
                if curBuffer.count > 0 {
                    throw NXSSError.Parse(msg: "You forgot to apply semi-colon to your last line.", statement: String(curBuffer), line: curLineNum)
                }
                // By now curBuffer is an empty string
            
                let oldContext = blockQueue.pop()
                if let oldContext = oldContext as? MixinBlock {
                    
                    let styleMixin : CompiledMixin = try oldContext.compile()
                    mixins[styleMixin.selector] = styleMixin
                    
                
                } else if let oldContext = oldContext as? RuleSetBlock {
                
                    let styleClass : CompiledRuleSet = try oldContext.compile()
                    ruleSets[styleClass.compiledKey] = styleClass
                
                } else {
                    assert(false,"Should never have gone here. Fatal logic error.")
                }
                
            }	 
                    
            // End of Line
            else if s == ";" {
                
                try processLine(&curBuffer, ruleSets: &ruleSets, curLineNum:  curLineNum)

                
            // Check for Open Comment
            } else if let last = curBuffer.last where s == "*" && last == "/" {
                
                curBuffer.removeLast()  // remove the saved "/", since we're going to ignore that.
                skip = true
                
            
            } else {
                
                curBuffer.append(s)
            }
            
        
            lastS = s
        }
        
        return ruleSets
            
    }
    
    private func processLine(inout curBuffer : String.CharacterView, inout ruleSets : [String:CompiledRuleSet] , curLineNum : Int ) throws {
        
        let (type,key,value) = try KeyValueParser.parse( String(curBuffer) )
        
        guard let curBlock = blockQueue.peek() else {
            throw NXSSError.Require(msg: "BlockQueue.peek() just failed", statement: "", line: nil)
        }
        
        switch type {
        case .Declaration, .VariableDeclaration:
            
            curBlock.addDeclaration(key,value: value)
            
        case .Include:
            
            let (selector,argVals) = try FunctionHeader.parse(value)
            
            guard let mixin = mixins[selector] else {
                throw NXSSError.Require(msg: "Cannot find mixin named \(selector)", statement: value, line:curLineNum)
            }
            
            curBlock.addDeclarations(
                mixin.resolveArguments(argVals)
            )
            
        case .Extend(let selectorType):
            
            var selector:String?
            var pseudoClass:PseudoClass?
            
            // We're going to extend from another class.
            switch try BlockHeader.parse(value) {
            case .Class(let selector_, let pseudoClass_):
                selector = selector_
                pseudoClass = pseudoClass_
                
            case .Element(let selector_, let pseudoClass_):
                selector = selector_
                pseudoClass = pseudoClass_
                
            default:
                break
            }
            
            if let selector = selector ,   pseudoClass = pseudoClass {
                
                let compiledKey = CompiledRuleSet.getCompiledKey(selector,selectorType: selectorType, pseudoClass: pseudoClass)
                
                guard let baseStyle = ruleSets[compiledKey] else {
                    NSLog("ruleSets \(ruleSets)")
                    throw NXSSError.Require(msg: "Cannot find class/element to extend from with name \(value)", statement: value, line:curLineNum)
                }
                
                curBlock.addDeclarations(baseStyle.declarations)
                
            } else {
                throw NXSSError.Parse(msg: "This extend does not contain Class or Element: \(value)", statement: value, line:curLineNum)
            }
            
        case .Import:
            
            // Let's start a new parser (recursive)
            let parser = try Parser(fileName: value, bundle: fileBundle , parentParser: self)
            try parser.parse()
            
            // Assign or Override the resulting ruleSet
            for (k,v) in parser.ruleSets {
                ruleSets[k] = v
            }
            
            // Assign or Override the Block
            self.blockQueue = parser.blockQueue
            
        }
        
        curBuffer.removeAll(keepCapacity: true)
    }
    
}