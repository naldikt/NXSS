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

        var curLineNum = 1  // line num starts from 1-based
        var curLine : String.CharacterView = String.CharacterView()
        curLine.reserveCapacity(100)
        
        var commandParser = CommandParser()
        
        var blockQueue = Queue<Block>()
        blockQueue.push(Block(selector: nil, parentBlock: nil))
        
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
                case .InProgress: continue    // Nothign todo.
                    
                case .Extend(let result):
                    
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
                    
                case .Include(let selector, let argumentValues):
                    
                    guard let mixin = mixins[selector] else {
                        throw NXSSError.Require(msg: "Cannot find mixin named \(selector)", statement: String(curLine), line:curLineNum)
                    }
                    
                    curBlock.addDeclarations(
                        try mixin.resolveArguments(argumentValues)
                    )
                    
                case .Import(let fileName):
                    break
                    
                case .StyleDeclaration(let key, let value):
                    curBlock.addDeclaration(key,value:value)
                    
                case .UIKitElementHeader(let selector, let pseudoClass):
                    blockQueue.push(
                        RuleSetBlock(selector:selector,
                                selectorType:.UIKitElement,
                                pseudoClass: pseudoClass,
                                parentBlock:blockQueue.peek())
                    )
                
                case .NXSSClassHeader(let selector, let pseudoClass):
                    blockQueue.push(
                        RuleSetBlock(selector:selector,
                                    selectorType:.NXSSClass,
                                     pseudoClass: pseudoClass,
                                     parentBlock:blockQueue.peek())
                    )
                    
                case .MixinHeader(let selector, let argumentNames):
                    blockQueue.push(
                        MixinBlock(selector:selector,
                                    argNames:argumentNames,
                                parentBlock:blockQueue.peek())
                    )
                    
                    
                case .BlockClosure:
                    
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
                

                commandParser = CommandParser()
                
            } else {
                // CommandParser doesn't have any idea what this line is.
            }
            
 

        }
    }
    
            
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