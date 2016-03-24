//
//  CommandParserResults.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/28/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

enum CPPathResolution {
    case InProgress         // The append is still in progress and has no definitive result.
    case Extend(selector:String, selectorType:SelectorType, pseudoClass:PseudoClass)
    case Include(selector:String, argumentValues:[String])
    case Import(fileName:String)
    case StyleDeclaration(key:String, value:String)
    case RuleSetHeader(selector:String, selectorType:SelectorType, pseudoClass:PseudoClass)
    case MixinHeader(selector:String, argumentNames:[String])
    case ScopeClosure
}

enum CPAppendResult {
    case InProgress    // can still take more characters
    case Invalid       // the character given's invalid. We shouldn't proceed with this CPPath.
    case Resolved(resolution:CPPathResolution)      // resolved.
}

private enum CPPathArgParseState {
    case Pre
    case In
    case Post
}

protocol CPAppendable {
    /*!
        Called by LineParser when it bumped into valid characters.
        By agreement, LineParser NOT going to pass:
        - Space before first real character
        - Comments-related character (/* and any characters in between */)
    */
    func append( c : CPChar , atIndex : CPCharViewIndex , latestData : CPData ) -> CPAppendResult
}

/*! Base class for reserved-key and value pair line. You need to subclass me. */
class _CPPathReservedKeyValueBase : CPAppendable {
    
    /** Anything after key is considered value. */
    init(key : [CPChar]) {
        self.key = key
    }
    
    func append( c : CPChar , atIndex : CPCharViewIndex , latestData : CPData ) -> CPAppendResult {
        
        if latestData.characters.count <= key.count {
            return verifyKey( c , atIndex: atIndex, latestData:  latestData)
            
        } else {
            // Handle Values
            let result = verifyValue( c, atIndex: atIndex, latestData:  latestData )
            switch result {
            case .InProgress:
                self.processValue( c, atIndex: atIndex, latestData:latestData)
            default:
                break
            }
            return result
        }
    }
    
    // MARK: Private
    
    private var key : [CPChar]
    private var valueIndexStart : CPCharViewIndex?
    
    
    private func verifyKey( c:CPChar,atIndex: CPCharViewIndex, latestData : CPData ) -> CPAppendResult {
        if key[latestData.characters.count-1] == c { return .InProgress }
        else { return .Invalid }
    }
    
    private func verifyValue( c:CPChar,atIndex: CPCharViewIndex , latestData : CPData ) -> CPAppendResult {
        if c == ";" {
            if let valueIndexStart = valueIndexStart where latestData.characters.endIndex != valueIndexStart {
                let value = latestData.trimmedStringWithRange(valueIndexStart, endIndex: atIndex)
                return resolve( value , c:c, atIndex:atIndex, latestData : latestData)
            } else {
                return .Invalid
            }
        } else {
            if valueIndexStart == nil {
                valueIndexStart = atIndex
            }
            return .InProgress
        }
    }
    
    /** Children are given the chance to process the given value. */
    private func processValue( c:CPChar, atIndex: CPCharViewIndex, latestData : CPData ) {
        // Nothing, please override and do anything you'd like.
        assert(false,"Override me")
    }
    
    /** Please return .Resolved() or .Invalid with children's type. */
    private func resolve( value: String , c : CPChar , atIndex : CPCharViewIndex , latestData : CPData ) -> CPAppendResult {
        assert(false,"Override me")
        return .Invalid
    }
}

class CPPathExtend : _CPPathReservedKeyValueBase  {
    
    /** "@extend .Foo:normal" or "@extend UIView:selected" */
    init() {
        if self.dynamicType.keyword == nil {
            self.dynamicType.keyword = stringToCPChars("@extend ")
        }
        super.init(key:self.dynamicType.keyword!)
    }
    
    // MARK: Private
    
    private static var keyword : [CPChar]?
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selectorStartIndex : CPCharViewIndex?
    private var selectorEndIndex : CPCharViewIndex?
    
    private var pseudoClassStartIndex : CPCharViewIndex?
    
    private var selectorType : SelectorType = .UIKitElement
    private var parseState : ParseState = .SelectorType
    
    private override func processValue(c:CPChar , atIndex: CPCharViewIndex, latestData : CPData ) {
        
        if c == " " { return }
        
        switch parseState {
        case .SelectorType:
            parseState = .Selector
            if c == "." {
                selectorType = .NXSSClass
            } else {
                self.processValue(c, atIndex: atIndex, latestData: latestData)
            }
            
        case .Selector:
            if c == ":" {
                selectorEndIndex = atIndex
                parseState = .PseudoClass
            } else if selectorStartIndex == nil {
                selectorStartIndex = atIndex
            }
            
        case .PseudoClass:
            if pseudoClassStartIndex == nil {
                pseudoClassStartIndex = atIndex
            }
        }
    }
    
    private override func resolve(value: String , c : CPChar , atIndex : CPCharViewIndex , latestData : CPData) -> CPAppendResult {
        // TODO: this isn't safe. I think resolveType should be throwable
        if selectorEndIndex == nil {
            selectorEndIndex = atIndex // endIndex is ";"
        }
        let selector = latestData.trimmedStringWithRange(selectorStartIndex!, endIndex: selectorEndIndex!)
        
        var pseudoClass : PseudoClass = .Normal
        if let pseudoClassStartIndex = pseudoClassStartIndex {
            let pseudoClassStr = latestData.trimmedStringWithRange(pseudoClassStartIndex, endIndex: latestData.characters.endIndex)
            let pc = PseudoClass(rawValue: pseudoClassStr)!
            pseudoClass = pc
        }
        return .Resolved(resolution: .Extend(selector:String(selector), selectorType:selectorType, pseudoClass:pseudoClass))
    }
    
}


class CPPathInclude : _CPPathReservedKeyValueBase {
    
    /** "@include foo(1,2,bar(3,4), aldi)" */
    init() {
        if self.dynamicType.keyword == nil {
            self.dynamicType.keyword = stringToCPChars("@include ")
        }
        super.init(key:self.dynamicType.keyword!)
    }

    // MARK: Private
    
    private static var keyword : [CPChar]?
    
    private var argumentParseState : CPPathArgParseState = .Pre
    
    private var selectorStartIndex : CPCharViewIndex?
    
    private var currentArgumentStartIndex : CPCharViewIndex?
    
    private var selectorResult : String = ""
    private var argumentValuesResut :[String] = []
    
    private var numOfParenthesis = 0  // helps with distinguishing between arg and sub-arg
    
    private override func processValue(c:CPChar, atIndex : CPCharViewIndex, latestData : CPData) {
        // We need to preserve spaces. e.g. "to bottom" for gradients.
        
        switch argumentParseState {
        case .Pre:
            if c == "(" {
                let lastIndex = atIndex
                selectorResult = latestData.trimmedStringWithRange(self.selectorStartIndex!, endIndex: lastIndex)
                argumentParseState = .In
            } else  if selectorStartIndex == nil {
                selectorStartIndex = atIndex
            }
            
        case .In:
            
            if c == "(" {
                numOfParenthesis += 1
            } else if c == ")" {
                numOfParenthesis -= 1
            }
            
            if c == ")" || (c  == "," && numOfParenthesis == 0) {
                
                if let currentArgumentStartIndex = currentArgumentStartIndex {
                    // May get here when a func is called without argument
                    let lastIndex = atIndex
                    let argVal = latestData.trimmedStringWithRange(currentArgumentStartIndex, endIndex: lastIndex)
                    argumentValuesResut.append(argVal)
                    self.currentArgumentStartIndex = nil
                }
                
                if c == ")" {
                    argumentParseState = .Post
                }
                
            } else if currentArgumentStartIndex == nil {
                currentArgumentStartIndex = atIndex
            }
            
        case .Post:
            break
        }
    }
    
    private override func resolve(value: String, c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) -> CPAppendResult {
        return .Resolved(resolution:.Include(selector:selectorResult, argumentValues : argumentValuesResut))
    }

    
}

class CPPathImport : _CPPathReservedKeyValueBase {
    
    /*!  "@import FileName;*/
    init() {
        if self.dynamicType.keyword == nil {
            self.dynamicType.keyword = stringToCPChars("@import ")
        }
        super.init(key:self.dynamicType.keyword!)
    }
    
    // MARK: Private
    
    private static var keyword : [CPChar]?
    
    private override func resolve(value: String, c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) -> CPAppendResult {
        return .Resolved(resolution: .Import(fileName:value))
    }
    
    private override func processValue(c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) {
        // Do nothing. Override since parent has assert.
    }
}

class CPPathStyleDeclaration :  CPAppendable {
    
    /*! Parses standard key-value style declaration e.g. "background-color: red;" */
    func append(c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) -> CPAppendResult {

        switch parseState {
        case .Key:
            if c  == ":" {
                let lastIndex = atIndex
                keyResult = latestData.trimmedStringWithRange(self.keyStartIndex!, endIndex: lastIndex)
                parseState = .Value
            } else if keyStartIndex == nil {
                keyStartIndex = atIndex
            }
        case .Value:
            if c == ";" {
                if let valueStartIndex = valueStartIndex where valueStartIndex != atIndex {
                    valueResult = latestData.trimmedStringWithRange(valueStartIndex, endIndex: atIndex)
                    if self.keyResult.characters.count > 0 && self.valueResult.characters.count > 0 {
                        return self.resolve()
                    }
                }
                return .Invalid
            } else if valueStartIndex == nil {
                valueStartIndex = atIndex
            }
        }
        
        return .InProgress
    }
    
    // MARK: Private
    
    private enum ParseState {
        case Key
        case Value
    }
    
    private var keyStartIndex : CPCharViewIndex?
    private var valueStartIndex : CPCharViewIndex?
    
    private var parseState : ParseState = .Key
    private var keyResult : String = ""
    private var valueResult : String = ""
    
    private func resolve() -> CPAppendResult {
        return .Resolved(resolution: .StyleDeclaration(key:self.keyResult,value:self.valueResult))
    }
}


class CPPathRuleSetHeader : CPAppendable {

    /*! Parses UIKitElement header e.g.  "UIButton:normal {" */
    func append(c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) -> CPAppendResult {

        switch parseState {
        case .SelectorType:
            if c == "{" {
                return resolve(atIndex, latestData:latestData)
            } else if c == "." {
                selectorType = .NXSSClass
                parseState = .Selector
            } else {
                selectorType = .UIKitElement
                parseState = .Selector
                return append(c, atIndex: atIndex, latestData: latestData)
            }
        case .Selector:
            if c == "{" {
                selectorEndIndex = atIndex
                return resolve(atIndex, latestData:latestData)
                
            } else if c == ":" {
            
                selectorEndIndex = atIndex
                parseState = .PseudoClass
                
            } else if selectorStartIndex == nil {
                selectorStartIndex = atIndex
            }
            
        case .PseudoClass:
            if c == "{" {
                return resolve(atIndex, latestData:latestData)
            } else if pseudoClassStartIndex == nil {
                pseudoClassStartIndex = atIndex
            }
        }
        return .InProgress
    }
    
    // MARK: Private
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selectorStartIndex : CPCharViewIndex?
    private var selectorEndIndex : CPCharViewIndex?
    private var pseudoClassStartIndex : CPCharViewIndex?
    
    private var selectorType : SelectorType = .NXSSClass
    private var parseState : ParseState = .SelectorType
    
    private func resolve(lastCharIndex : CPCharViewIndex, latestData : CPData) -> CPAppendResult {

        var pseudoClassResult : PseudoClass = .Normal

        if let pseudoClassStartIndex = pseudoClassStartIndex {
            let lastIndex = lastCharIndex
            let pcStr = latestData.trimmedStringWithRange(pseudoClassStartIndex, endIndex: lastIndex)
            if let pc = PseudoClass(rawValue: pcStr) {
                pseudoClassResult = pc
            } else {
                return .Invalid
            }
        }
        
        var selectorResult = ""
        
        selectorResult = latestData.trimmedStringWithRange(self.selectorStartIndex!, endIndex: selectorEndIndex!)
        if selectorResult.characters.count == 0 {
            return .Invalid
        }
        
        return .Resolved(resolution:.RuleSetHeader(selector:selectorResult, selectorType:selectorType, pseudoClass:pseudoClassResult))
    }

}

class CPPathMixinHeader: CPAppendable   {
    
    init() {
        if self.dynamicType.keyword == nil {
            self.dynamicType.keyword = stringToCPChars("@mixin ")
        }
        self.keyword = self.dynamicType.keyword!
    }
 
    /** Solves "@mixin foo($a,$b) {" */
    func append(c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) -> CPAppendResult {
        
        if latestData.characters.count <= keyword.count {
            
            if c == keyword[latestData.characters.count-1] {
                return .InProgress
            }
            else {
                return .Invalid
            }
            
            
        } else if argumentParseState == .Pre {
            if c == "("  {
                
                let lastIndex = atIndex
                selectorResult = latestData.trimmedStringWithRange(self.selectorStartIndex!, endIndex: lastIndex)
                argumentParseState = .In
                
            } else if selectorStartIndex == nil {
                selectorStartIndex = atIndex
            }
            
        } else if argumentParseState == .In  {
            
            if c == "," || c == ")" {
                
                if let currentArgumentStartIndex = currentArgumentStartIndex {
                    // May get here when you do "foo()"
                    let lastIndex = atIndex
                    let argName = latestData.trimmedStringWithRange(currentArgumentStartIndex, endIndex: lastIndex)
                    if argName.characters.count > 0 {
                        argumentNamesResult.append(argName)
                    }
                }

                currentArgumentStartIndex = nil
                
                if c == ")" {
                    argumentParseState = .Post
                }
                
            } else if currentArgumentStartIndex == nil {
                
                currentArgumentStartIndex = atIndex
                
            }
            
        } else if c == "{" {
            if argumentParseState == .Pre || argumentParseState == .Post {
                return resolve()
            } else {
                return .Invalid
            }
        }
        
        return .InProgress
        
    }
    
    // MARK: Private
    
    private static var keyword : [CPChar]?
    private let keyword : [CPChar]
    
    private var argumentParseState : CPPathArgParseState = .Pre

    private var selectorStartIndex : CPCharViewIndex?
    private var currentArgumentStartIndex : CPCharViewIndex?
    
    private var selectorResult = ""
    private var argumentNamesResult : [String] = []
    
    private func resolve() -> CPAppendResult {
        return .Resolved(resolution: .MixinHeader(selector:selectorResult, argumentNames:argumentNamesResult))
    }
}

class CPPathScopeClosure : CPAppendable   {

    /** Solves end of scope/rule-set "}" */
    func append(c: CPChar, atIndex: CPCharViewIndex, latestData: CPData) -> CPAppendResult {
        if latestData.characters.count == 1 && c == "}" {
            return .Resolved(resolution:.ScopeClosure)
        } else {
            return .Invalid
        }
    }
}