//
//  FileEvaluator.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 3/21/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

/**
 
 A component used by Parser, FileParser takes in (if applicable) a Scope, and execute the content of a specified file to the given Scope.
 
*/
class FileEvaluator {
    
    init(fileName:String, bundle : NSBundle? = nil ) {
        self.fileName = fileName
        self.bundle = bundle
    }
    
    func eval(mainScope:Scope) throws -> Scope {
        
        guard let filePath = self.dynamicType.pathForFile(fileName, bundle:bundle) else {
            throw NXSSError.Require(msg: "FilePath does not exist", statement: fileName, line: nil)
        }
        guard let data = NSData(contentsOfFile:filePath) else {
            throw NXSSError.Require(msg: "Data from path is invalid", statement: filePath, line: nil)
        }
        guard let fileContent = NSString(data: data, encoding: NSUTF8StringEncoding) as? String else {
            throw NXSSError.Require(msg: "Data cannot be converted to String", statement: "<cannot print data>", line: nil)
        }
        
        return try traverse(fileContent , mainScope: mainScope)

    }
    
    // MARK: Private
    
    private let fileName : String
    private let bundle : NSBundle?
    private static let fileExtension = ".nxss"
    
    private func traverse(fileContent:String, mainScope: Scope) throws -> Scope {
        
        // Prepare debugging in case there's exception.
        var curLineNum = 1  // line num starts from 1-based
        var curLine  = CPCharView()
        curLine.reserveCapacity(100)
        
        // Setup current Scope
        var curScope = mainScope
        
        // CommandParser
        var commandParser = CommandParser()
        
        // Let's start the FUN!
        let chars = getCPChars(fileContent)
        for c:CPChar in chars {
            
            // Debugging purpose. Keep track of the lines.
            curLine.append(c)
            if c == "\n" {
                curLineNum += 1
                curLine.removeAll()
            }
            
            // Run the Parser.
            if let resultType : CPPathResolution = commandParser.append(c) {
                switch resultType {
                    
                    // MARK: InProgress
                case .InProgress:
                    
                    continue    // Nothign todo.
                    
                    // MARK: Extend
                case .Extend(let selector, let selectorType, let pseudoClass):
                    let compiledKey = CompiledRuleSet.getCompiledKey(selector,selectorType: selectorType, pseudoClass: pseudoClass)
                    
                    guard let baseStyle = mainScope.compiledRuleSets[compiledKey] else {
                        throw NXSSError.Require(msg: "Cannot find class/element to extend from with name \"\(selector)\"", statement: String(curLine), line:curLineNum)
                    }
                    
                    curScope.addDeclarations(baseStyle.declarations)
                    
                    
                    // MARK: Include
                case .Include(let selector, let argumentValues):
                    
                    guard let mixin = mainScope.compiledMixins[selector] else {
                        throw NXSSError.Require(msg: "Cannot find mixin named \(selector)", statement: String(curLine), line:curLineNum)
                    }
                    
                    curScope.addDeclarations(
                        try mixin.resolveArguments(argumentValues)
                    )
                    
                    // MARK: Import
                case .Import(let fileName):
                    // Let's start a new FileEvaluator (recursive)
                    let evaluator = FileEvaluator(fileName: fileName, bundle: bundle)
                    curScope = try evaluator.eval(curScope)
                    
                    
                    // MARK: StyleDeclaration
                case .StyleDeclaration(let key, let value):
                    curScope.addDeclaration(key,value:value)
                    
                    // MARK: RuleSetHeader
                case .RuleSetHeader(let selector, let selectorType, let pseudoClass):
                    let newScope =
                    RuleSetScope(selector:selector,
                        selectorType: selectorType,
                        pseudoClass: pseudoClass,
                        parentScope:curScope)
                    
                    curScope = newScope
                    
                    // MARK: MixinHeader
                case .MixinHeader(let selector, let argumentNames):
                    let newScope =
                    MixinScope(selector:selector,
                        argNames:argumentNames,
                        parentScope:curScope)
                    
                    curScope = newScope
                    
                    // MARK: ScopeClosure
                case .ScopeClosure:
                    
                    // Attempt to dequeue
                    let oldScope = curScope
                    guard let cb = curScope.parentScope else {
                        throw NXSSError.Logic(msg: "There should always be parentScope. Fatal logic error.", statement:  String(curLine) , line:curLineNum)
                    }
                    curScope = cb
                    
                    if let oldScope = oldScope as? MixinScope {
                        
                        let styleMixin : CompiledMixin = try oldScope.compile()
                        curScope.addCompiledMixin(styleMixin, key: styleMixin.selector)
                        
                        
                    } else if let oldScope = oldScope as? RuleSetScope {
                        
                        let styleClass : CompiledRuleSet = try oldScope.compile()
                        curScope.addCompiledRuleSet(styleClass, key:styleClass.compiledKey)
                        
                    } else {
                        throw NXSSError.Parse(msg: "Too many close bracket.", statement: String(curLine), line: curLineNum)
                        
                    }
                }
                
                commandParser = CommandParser()
                
            } else {
                // CommandParser doesn't have any idea what this line is.
                NXSSError.Parse(msg: "Cannot parse line", statement: String(curLine), line: curLineNum)
            }
        } // end for loop
        
        assert( curScope === mainScope , "There is something wrong. This popped scope should've been the main scope" )
        
        return curScope
        
    } // end method
    
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
                fileNameToLookUp.endIndex.advancedBy(-self.fileExtension.characters.count) ..<
                fileNameToLookUp.endIndex
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
}