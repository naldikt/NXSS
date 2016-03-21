//
//  CommandParserResults.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/28/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

let CPBufferInitialLength : Int = 150

func createCharacterView() -> String.CharacterView {
    var ret = String.CharacterView()
    ret.reserveCapacity(CPBufferInitialLength)
    return ret
}

func createCharacterView(initialCharacter : Character) -> String.CharacterView {
    var ret = createCharacterView()
    ret.append(initialCharacter)
    return ret
}

enum CPAppendResult {
    case InProgress    // can still take more characters
    case Invalid       // the character given's invalid. We shouldn't proceed with this CPResult.
    case Resolved      // resolved.
}

private enum CPResultArgParseState {
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
    func characterAppended( c : Character , currentData : CParserData ) -> CPAppendResult
}

protocol CPResultTypeResolvable {
    func resolveType( currentData : CParserData ) -> CPResultType
}


/*! Base class for reserved-key and value pair line. You need to subclass me. */
class _CPResultReservedKeyValueBase : CPAppendable{
    
    /** Anything after key is considered value. */
    init(key : [Character]) {
        self.key = key
    }
    
    func characterAppended(c:Character, currentData : CParserData) -> CPAppendResult {
        
        if currentData.characters.count <= key.count {
            return verifyKey( c , currentData:  currentData)
            
        } else if valueIndexStart == nil && c == " " {
            
            // handles space between keyword and selector name
            return .InProgress
            
        } else {
            // Handle Values
            let result = verifyValue( c, currentData:  currentData )
            switch result {
            case .InProgress:
                self.processValue( c, currentData:currentData)
            default:
                break
            }
            return result
        }
    }
    
    // MARK: Private
    
    private var key : [Character]
    private var valueResult : String = ""
    private var valueIndexStart : String.CharacterView.Index?
    
    
    private func verifyKey( c:Character, currentData : CParserData ) -> CPAppendResult {
        if key[currentData.characters.count] == c { return .InProgress }
        else { return .Invalid }
    }
    
    private func verifyValue( c:Character, currentData : CParserData ) -> CPAppendResult {
        if c == ";" {
            if let valueIndexStart = valueIndexStart where currentData.lastCharacterIndex != valueIndexStart {
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                valueResult = currentData.trimmedStringWithRange(valueIndexStart, endIndex: lastIndex)
                return .Resolved
            } else {
                return .Invalid
            }
        } else {
            if valueIndexStart == nil {
                valueIndexStart = currentData.lastCharacterIndex
            }
            return .InProgress
        }
    }
    
    private func processValue( c:Character, currentData : CParserData ) {
        // Nothing, please override and do anything you'd like.
        assert(false,"Override me")
    }
}

class CPResultExtend : _CPResultReservedKeyValueBase , CPResultTypeResolvable {
    
    /** "@extend .Foo:normal" or "@extend UIView:selected" */
    init() {
        struct Static {
            static var token: dispatch_once_t = 0
            static var keyword : [Character] = []
        }
        dispatch_once(&Static.token) {
            let key = "@extend "
            var keyword : [Character] = []
            for k in key.characters {
                keyword.append(k)
            }
            Static.keyword = keyword
        }
        super.init(key: Static.keyword)
        
    }
    
    func resolveType( currentData : CParserData ) -> CPResultType {
        
        // TODO: this isn't safe. I think resolveType should be throwable
        let selector = currentData.trimmedStringWithRange(selectorStartIndex!, endIndex: selectorEndIndex!)
        
        var pseudoClass : PseudoClass = .Normal
        if let pseudoClassStartIndex = pseudoClassStartIndex {
            let pseudoClassStr = currentData.trimmedStringWithRange(pseudoClassStartIndex, endIndex: currentData.lastCharacterIndex)
            let pc = PseudoClass(rawValue: pseudoClassStr)!
            pseudoClass = pc
        }
        return .Extend(selector:String(selector), selectorType:selectorType, pseudoClass:pseudoClass)
    }
    
    // MARK: Private
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selectorStartIndex : String.CharacterView.Index?
    private var selectorEndIndex : String.CharacterView.Index?
    
    private var pseudoClassStartIndex : String.CharacterView.Index?
    
    private var selectorType : SelectorType = .UIKitElement
    private var parseState : ParseState = .SelectorType
    
    private override func processValue(c:Character , currentData : CParserData ) {
        
        if c == " " { return }
        
        switch parseState {
        case .SelectorType:
            parseState = .Selector
            if c == "." {
                selectorType = .NXSSClass
            } else {
                self.processValue(c, currentData: currentData)
            }
            
        case .Selector:
            if c == ":" {
                selectorEndIndex = currentData.lastCharacterIndex.predecessor()
                parseState = .PseudoClass
            } else if selectorStartIndex == nil {
                selectorStartIndex = currentData.lastCharacterIndex
            }
            
        case .PseudoClass:
            if pseudoClassStartIndex == nil {
                pseudoClassStartIndex = currentData.lastCharacterIndex
            }
        }
    }
    
}


class CPResultInclude : _CPResultReservedKeyValueBase , CPResultTypeResolvable {
    
    /** "@include foo(1,2,bar(3,4), aldi)" */
    init() {
        struct Static {
            static var token: dispatch_once_t = 0
            static var keyword : [Character] = []
        }
        dispatch_once(&Static.token) {
            let key = "@include "
            var keyword : [Character] = []
            for k in key.characters {
                keyword.append(k)
            }
            Static.keyword = keyword
        }
        
        super.init(key: Static.keyword)
    }
    
    func resolveType( currentData : CParserData ) -> CPResultType {
        return .Include(selector:selectorResult, argumentValues : argumentValuesResut)
    }
    
    // MARK: Override
    
    private override func processValue(c : Character, currentData : CParserData) {
        // We need to preserve spaces. e.g. "to bottom" for gradients.
        
        switch argumentParseState {
        case .Pre:
            if c == "(" {
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                selectorResult = currentData.trimmedStringWithRange(self.selectorStartIndex!, endIndex: lastIndex)
                argumentParseState = .In
            } else  if selectorStartIndex == nil {
                selectorStartIndex = currentData.lastCharacterIndex
            }
            
        case .In:
            
            if c == "(" {
                numOfParenthesis += 1
            } else if c == ")" {
                numOfParenthesis -= 1
            }
            
            if c == ")" || (c  == "," && numOfParenthesis == 0) {
                
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                let argVal = currentData.trimmedStringWithRange(self.currentArgumentStartIndex!, endIndex: lastIndex)
                argumentValuesResut.append(argVal)
                currentArgumentStartIndex = nil
                
                if c == ")" {
                    argumentParseState = .Post
                }
                
            } else if currentArgumentStartIndex == nil {
                currentArgumentStartIndex = currentData.lastCharacterIndex
            }
            
        case .Post:
            break
        }
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    
    private var selectorStartIndex : String.CharacterView.Index?
    
    private var currentArgumentStartIndex : String.CharacterView.Index?

    private var selectorResult : String = ""
    private var argumentValuesResut :[String] = []
    
    private var numOfParenthesis = 0  // helps with distinguishing between arg and sub-arg
    
}

class CPResultImport : _CPResultReservedKeyValueBase, CPResultTypeResolvable {
    
    /*!  "@import FileName;*/
    init() {
        struct Static {
            static var token: dispatch_once_t = 0
            static var keyword : [Character] = []
        }
        dispatch_once(&Static.token) {
            let key = "@import "
            var keyword : [Character] = []
            for k in key.characters {
                keyword.append(k)
            }
            Static.keyword = keyword
        }
        super.init(key: Static.keyword)
    }
    
    func resolveType( currentData : CParserData ) -> CPResultType {
        return .Import(fileName:valueResult)
    }
    
    private override func processValue( c: Character , currentData : CParserData  ) {
        // nothing
    }
}

class CPResultStyleDeclaration : CPResultTypeResolvable ,CPAppendable {

    func resolveType( currentData : CParserData ) -> CPResultType {
        return .StyleDeclaration(key:self.keyResult,value:self.valueResult)
    }
    
    /*! Parses standard key-value style declaration e.g. "background-color: red;" */
    func characterAppended(c:Character , currentData : CParserData ) -> CPAppendResult {

        switch parseState {
        case .Key:
            if c  == ":" {
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                keyResult = currentData.trimmedStringWithRange(self.keyStartIndex!, endIndex: lastIndex)
                parseState = .Value
            } else if keyStartIndex == nil {
                keyStartIndex = currentData.lastCharacterIndex
            }
        case .Value:
            if c == ";" {
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                valueResult = currentData.trimmedStringWithRange(self.valueStartIndex!, endIndex: lastIndex)

                if self.keyResult.characters.count > 0 && self.valueResult.characters.count > 0 {
                    return .Resolved
                } else {
                    return .Invalid
                }
            } else if valueStartIndex == nil {
                valueStartIndex = currentData.lastCharacterIndex
            }
        }
        
        return .InProgress
    }
    
    // MARK: Private
    
    private enum ParseState {
        case Key
        case Value
    }
    
    private var keyStartIndex : String.CharacterView.Index?
    private var valueStartIndex : String.CharacterView.Index?
    
    private var parseState : ParseState = .Key
    private var keyResult : String = ""
    private var valueResult : String = ""
}


class CPResultRuleSetHeader :  CPResultTypeResolvable,CPAppendable  {
    
    func resolveType(currentData : CParserData) -> CPResultType {
        return .RuleSetHeader(selector:selectorResult, selectorType:selectorType, pseudoClass:pseudoClassResult)
    }

    /*! Parses UIKitElement header e.g.  "UIButton:normal {" */
    func characterAppended(c: Character , currentData : CParserData) -> CPAppendResult {
        switch parseState {
        case .SelectorType:
            if c == "{" {
                return finalize(currentData)
            } else if c == "." {
                selectorType = .NXSSClass
                parseState = .Selector
            } else {
                selectorType = .UIKitElement
                parseState = .Selector
                return characterAppended(c, currentData: currentData)
            }
        case .Selector:
            if c == "{" {
                
                return finalize(currentData)
                
            } else if c == ":" {
            
                selectorEndIndex = currentData.lastCharacterIndex
                parseState = .PseudoClass
                
            } else if selectorStartIndex == nil {
                selectorStartIndex = currentData.lastCharacterIndex
            }
            
        case .PseudoClass:
            if c == "{" {
                return finalize(currentData)
            } else if pseudoClassStartIndex == nil {
                pseudoClassStartIndex = currentData.lastCharacterIndex
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
    
    private var selectorStartIndex : String.CharacterView.Index?
    private var selectorEndIndex : String.CharacterView.Index?
    private var pseudoClassStartIndex : String.CharacterView.Index?
    
    private var selectorType : SelectorType = .NXSSClass
    private var parseState : ParseState = .SelectorType
    
    private var pseudoClassResult : PseudoClass = .Normal
    private var selectorResult = ""
    
    private func finalize(currentData : CParserData) -> CPAppendResult {
        // End of command. Let's process.

        if let pseudoClassStartIndex = pseudoClassStartIndex {
            let lastIndex = currentData.lastCharacterIndex.predecessor()
            let pcStr = currentData.trimmedStringWithRange(pseudoClassStartIndex, endIndex: lastIndex)
            if let pc = PseudoClass(rawValue: pcStr) {
                self.pseudoClassResult = pc
            } else {
                return .Invalid
            }
        }
        
        let lastIndex = currentData.lastCharacterIndex.predecessor()
        selectorResult = currentData.trimmedStringWithRange(self.selectorStartIndex!, endIndex: lastIndex)
        if selectorResult.characters.count == 0 {
            return .Invalid
        }
        
        return .Resolved
    }
    
}

class CPResultMixinHeader:CPAppendable , CPResultTypeResolvable {
    
    init() {
        struct Static {
            static var token: dispatch_once_t = 0
            static var keyword : [Character] = []
        }
        dispatch_once(&Static.token) {
            let key = "@mixin "
            var keyword : [Character] = []
            for k in key.characters {
                keyword.append(k)
            }
            Static.keyword = keyword
        }
        self.keyword = Static.keyword
    }
    
    func resolveType( currentData : CParserData ) -> CPResultType {
        return .MixinHeader(selector:selectorResult, argumentNames:argumentNamesResult)
    }
 
    /** Solves "@mixin foo($a,$b) {" */
    func characterAppended(c: Character,currentData : CParserData) -> CPAppendResult {
        
        if currentData.characters.count <= keyword.count {
            
            if c == keyword[currentData.characters.count-1] {
                return .InProgress
            }
            else {
                return .Invalid
            }
            
            
        } else if argumentParseState == .Pre {
            if c == "("  {
                
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                selectorResult = currentData.trimmedStringWithRange(self.selectorStartIndex!, endIndex: lastIndex)
                argumentParseState = .In
                
            } else if selectorStartIndex == nil {
                selectorStartIndex = currentData.lastCharacterIndex
            }
            
        } else if argumentParseState == .In  {
            
            if c == "," || c == ")" {
                
                let lastIndex = currentData.lastCharacterIndex.predecessor()
                let argName = currentData.trimmedStringWithRange(self.currentArgumentStartIndex!, endIndex: lastIndex)
                argumentNamesResult.append(argName)

                currentArgumentStartIndex = nil
                
                if c == ")" {
                    argumentParseState = .Post
                }
                
            } else if currentArgumentStartIndex == nil {
                
                currentArgumentStartIndex = currentData.lastCharacterIndex
                
            }
            
        } else if c == "{" {
            if argumentParseState == .Pre || argumentParseState == .Post {
                return .Resolved
            } else {
                return .Invalid
            }
        }
        
        return .InProgress
        
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    private var keyword : [Character] = []

    private var selectorStartIndex : String.CharacterView.Index?
    private var currentArgumentStartIndex : String.CharacterView.Index?
    
    private var selectorResult = ""
    private var argumentNamesResult : [String] = []
}

class CPResultBlockClosure:CPAppendable , CPResultTypeResolvable  {

    func resolveType(currentData : CParserData) -> CPResultType {
        return .BlockClosure
    }
    
    /** Solves end of block/rule-set "}" */
    func characterAppended(c: Character, currentData : CParserData) -> CPAppendResult {
        if currentData.characters.count == 1 && c == "}" {
            return .Resolved
        } else {
            return .Invalid
        }
    }
}