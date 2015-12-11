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
    
    init( fileName : String , bundle : NSBundle? = nil ) {
        
        self.fileName = fileName
        let filePath = Parser.pathForFile(fileName, bundle:bundle)
        let data = NSData(contentsOfFile:filePath!)
        assert(data != nil , "Could not find file \(filePath). Ensure it exists, and use NXSS.pathForFile() to generate the path.")
        self.fileContent = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        blockQueue.push(Block())
    }
    

	/**
		Parses the input string.
		:return:	dictionary
				String => Name of the style class.
				StyleClass => Parsed, compiled entries.
	*/
	func parse() throws -> [String:CompiledRuleSet] {
        do {
            
            let ret = try traverse()
            return ret
            
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
    
    let fileContent : String
    
    private var mixins : [String:CompiledMixin] = Dictionary()		// mixinName => StyleMixin
    
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
    
    private let blockQueue : Queue<Block> = Queue()
    
    private func traverse() throws -> [String:CompiledRuleSet] {

        var ryleSets : [String:CompiledRuleSet] = Dictionary()  // ret val
        var skip = false
        var lastS:unichar?
        var curLineNum = 1  // line num starts from 1-based
        
        let unichar_forwardSlash = "/".characterAtIndex(0)
        let unichar_asterisk = "*".characterAtIndex(0)
        let unichar_space = " ".characterAtIndex(0)
        let unichar_newLine = "\n".characterAtIndex(0)
        let unichar_semiColon = ";".characterAtIndex(0)
        let unichar_bracketOpen = "{".characterAtIndex(0)
        let unichar_bracketClose = "}".characterAtIndex(0)
        
        
        let bufferLength = 1000  // play with this value as neded
        var curBuffer : [unichar] = []
        curBuffer.reserveCapacity(bufferLength)
        
        let tempBuffer = UnsafeMutablePointer<unichar>.alloc(bufferLength)
        
        let inputNSString = fileContent as NSString
        
        var lastRange : Int = 0
        
        repeat {
        
            var rangeLength = bufferLength
            if lastRange + rangeLength >= fileContent.characters.count {
                rangeLength = fileContent.characters.count - lastRange
            }
            let realRange = inputNSString.rangeOfComposedCharacterSequencesForRange(NSMakeRange( lastRange , rangeLength ) )
            inputNSString.getCharacters(tempBuffer, range:  realRange)
            lastRange = lastRange + rangeLength
            
            for i in (0..<realRange.length) {
                let s : unichar = tempBuffer[i]
                
                if skip {
                    
                    // Check for Close comment
                    if let lastS = lastS where s == unichar_forwardSlash && lastS == unichar_asterisk {
                        skip = false
                    }
                    continue
                    
                } else if s == unichar_space {
                    
                    // We don't need empty spaces.
                    continue
                    
                } else if s == unichar_newLine {
                    
                    curLineNum++
                    continue
                    
                }

                // Start of Context
                if s == unichar_bracketOpen {
                    
                
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
                } else if s == unichar_bracketClose {
                    
                    if curBuffer.count > 0 {
                        assert(false,"You forgot to apply semi-colon to your last line.")
                    }
                    // By now curBuffer is an empty string
                
                    let oldContext = blockQueue.pop()
                    if let oldContext = oldContext as? MixinBlock {
                        
                        let styleMixin : CompiledMixin = try oldContext.compile()
                        mixins[styleMixin.selector] = styleMixin
                        
                    
                    } else if let oldContext = oldContext as? RuleSetBlock {
                    
                        let styleClass : CompiledRuleSet = try oldContext.compile()
                        ryleSets[styleClass.compiledKey] = styleClass
                    
                    } else {
                        assert(false,"Should never have gone here. Fatal logic error.")
                    }
                    
                }	 
                        
                // End of Line
                else if s == unichar_semiColon {
                    
                    let (type,key,value) = try KeyValueParser.parse(
                        NSString(characters: &curBuffer, length: realRange.length) as String
                    )
                    
                    let curBlock = blockQueue.peek()
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
                            
                            guard let baseStyle = ryleSets[compiledKey] else {
                                NSLog("ruleSets \(ryleSets)")
                                throw NXSSError.Require(msg: "Cannot find class/element to extend from with name \(value)", statement: value, line:curLineNum)
                            }
                            
                            curBlock.addDeclarations(baseStyle.declarations)
                            
                        } else {
                            throw NXSSError.Parse(msg: "This extend does not contain Class or Element: \(value)", statement: value, line:curLineNum)
                        }
                        
                    }
                
                    curBuffer.removeAll(keepCapacity: true)
                    
                    
                // Check for Open Comment
                } else if let last = curBuffer.last where s == unichar_asterisk && last == unichar_forwardSlash {
                    
                    curBuffer.removeLast()
                    skip = true
                    
                
                } else {
                    
                    curBuffer.append(s)
                }
                
            
                lastS = s
            }
        } while( lastRange < fileContent.characters.count )
        
        return ryleSets
            
    }
    
}