//
//  CommandParserResults.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/28/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

let CPBufferInitialLength : Int = 50

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
    func append( c : Character ) -> CPAppendResult
}

protocol CPResultTypeResolvable {
    func resolveType() -> CPResultType
}

class _CPResultBase : CPAppendable {
    
    init() {
        self.characters = createCharacterView()
    }
    
    func append(c: Character) -> CPAppendResult {
        
        characters.append(c)
        return characterAppended(c)

//        switch appendState {
//        case .Append:
//            if c == "/" {
//                appendState = .PossiblyStartSkip
//                
//            } else if characters.count == 0 &&
//                (c == " " || c == "\t" || c == "\n" || c == "\r") {
//                    
//                // Intentionally skip
//                    
//            } else {
//                characters.append(c)
//                return characterAppended(c)
//            }
//        case .PossiblyStartSkip:
//            if c == "*" {
//                appendState = .Skip
//            } else {
//                appendState = .Append
//                
//                // Attempt to restore
//                characters.append("/")
//                let ret1 = characterAppended("/")
//                if ret1 == .InProgress {
//                    characters.append(c)
//                    return characterAppended(c)
//                } else {
//                    return ret1
//                }
//            }
//        case .Skip:
//            if c == "*" {
//                appendState = .PossiblyEndSkip
//            }
//        case .PossiblyEndSkip:
//            if c == "/" {
//                appendState = .Append
//            } else if c == "*" {
//                // still same state
//            } else {
//                // Still skipping!
//                appendState = .Skip
//            }
//        }
//        return .InProgress
        
    }
    
    // MARK: Override Me
    
    private func characterAppended(c:Character) -> CPAppendResult {
        assert(false,"Override me")
        return .Invalid
    }
    
    
    // MARK: Private 
    
    private enum AppendState {
        case Append
        case PossiblyStartSkip
        case Skip
        case PossiblyEndSkip
    }
    
    private var skip = false
    private var characters : String.CharacterView
    private var appendState : AppendState = .Append
    
}

/*! Base class for reserved-key and value pair line. You need to subclass me. */
class _CPResultReservedKeyValueBase : _CPResultBase {
    
    /** Anything after key is considered value. */
    init(key : [Character]) {
        self.key = key
        self.value = createCharacterView()
    }
    
    // MARK: Overrides
    
    private override func characterAppended(c:Character) -> CPAppendResult {
        return verify(characters.count-1, added : c)
    }
    
    // MARK: Private
    
    private var key : [Character]
    private var value : String.CharacterView
    
    private func verify( index : Int , added c : Character ) -> CPAppendResult {
        if characters.count <= key.count {
            return verifyKey( index , added : c )
        } else if value.count == 0 && c == " " {
            // handles space between keyword and selector name
            return .InProgress
        } else {
            let result = verifyValue( index, added : c )
            switch result {
            case .InProgress:
                self.processValue( index,added:c)
            case .Resolved:
                if value.count == 0 {
                    return .Invalid
                }
            default:
                break
            }
            return result
        }
    }
    
    private func verifyKey( index : Int , added c : Character ) -> CPAppendResult {
        if key[index] == c { return .InProgress }
        else { return .Invalid }
    }
    
    private func verifyValue( index : Int , added c : Character ) -> CPAppendResult {

        if c == ";" {
            if value.count == 0 {
                return .Invalid
            }
            return .Resolved
            
//        } else if c == " " {
//            return .InProgress // skip
            
        } else {
            value.append(c)
            return .InProgress
        }

    }
    
    private func processValue( index:Int, added c : Character ) {
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
        self.selector = createCharacterView()
        super.init(key: Static.keyword)
        
    }
    
    func resolveType() -> CPResultType {
        return .Extend(selector:String(selector), selectorType:selectorType, pseudoClass:pseudoClass)
    }
    
    // MARK: Private
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selector : String.CharacterView
    private var selectorType : SelectorType = .UIKitElement
    private var pseudoClass : PseudoClass = .Normal
    private var parseState : ParseState = .SelectorType
    
    private override func processValue(index: Int, added c: Character) {
        
        if c == " " { return }
        
        switch parseState {
        case .SelectorType:
            parseState = .Selector
            if c == "." {
                selectorType = .NXSSClass
            } else {
                self.processValue(index, added: c)
            }
            
        case .Selector:
            if c == ":" {
                parseState = .PseudoClass
            } else {
                selector.append(c)
            }
            
        case .PseudoClass:
            selector.append(c)
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
        
        self.currentArgument = createCharacterView()
        self.selectorBuffer = createCharacterView()
        super.init(key: Static.keyword)
    }
    
    func resolveType() -> CPResultType {
        let argVals = self.argumentValues.map { (charView) in
            return String(charView).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        return .Include(selector:String(selectorBuffer), argumentValues : argVals)
    }
    
    // MARK: Override
    
    private override func processValue(index : Int , added c : Character) {
        // We need to preserve spaces. e.g. "to bottom" for gradients.
        
        switch argumentParseState {
        case .Pre:
            if c == "(" {
                argumentParseState = .In
            } else  {
                selectorBuffer.append(c)
            }
            
        case .In:
            
            if c == "(" {
                numOfParenthesis += 1
            } else if c == ")" {
                numOfParenthesis -= 1
            }
            
            if c == ")" {
                argumentValues.append(currentArgument)
                currentArgument = createCharacterView()
                
                argumentParseState = .Post
                
            } else if c  == "," && numOfParenthesis == 0 {
                argumentValues.append(currentArgument)
                currentArgument = createCharacterView()
                
            } else {
                currentArgument.append(c)
                
            }
            
        case .Post:
            break
        }
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    private var currentArgument : String.CharacterView
    private var selectorBuffer : String.CharacterView
    private var argumentValues:[String.CharacterView] = []
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
    
    func resolveType() -> CPResultType {
        return .Import(fileName:String(value))
    }
    
    private override func processValue(index: Int, added c: Character) {
        // nothing
    }
}

class CPResultStyleDeclaration : _CPResultBase , CPResultTypeResolvable {
    
    override init() {
        self.keyBuffer = createCharacterView()
        self.valueBuffer = createCharacterView()
        super.init()
    }

    func resolveType() -> CPResultType {
        return .StyleDeclaration(key:self.keyResult,value:self.valueResult)
    }
    
    // MARK: Override
    
    /*! Parses standard key-value style declaration e.g. "background-color: red;" */
    private override func characterAppended(c:Character) -> CPAppendResult {

        switch parseState {
        case .Key:
            if c  == ":" {
                parseState = .Value
            } else {
                keyBuffer.append(c)
            }
        case .Value:
            if c == ";" {
                self.keyResult = String(keyBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                self.valueResult = String(valueBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if self.keyResult.characters.count > 0 && self.valueResult.characters.count > 0 {
                    return .Resolved
                } else {
                    return .Invalid
                }
//            } else if c == " " && value.characters.count == 0 {
//                // Skip. Do not prepend spaces.
            } else {
                valueBuffer.append(c)
            }
        }
        
        return .InProgress
    }
    
    // MARK: Private
    
    private enum ParseState {
        case Key
        case Value
    }
    
    private var keyBuffer : String.CharacterView
    private var valueBuffer : String.CharacterView
    private var parseState : ParseState = .Key
    private var keyResult : String = ""
    private var valueResult : String = ""
}

class _CPResultBaseHeader : _CPResultBase {
    
}

class CPResultRuleSetHeader : _CPResultBaseHeader , CPResultTypeResolvable {
    
    override init() {
        self.selectorBuffer = createCharacterView()
        self.pseudoClassStringBuffer = createCharacterView()
        super.init()
    }
    
    func resolveType() -> CPResultType {
        return .RuleSetHeader(selector:selectorResult, selectorType:selectorType, pseudoClass:pseudoClass)
    }
    
    // MARK: Override
    
    /*! Parses UIKitElement header e.g.  "UIButton:normal {" */
    private override func characterAppended(c: Character) -> CPAppendResult {
        return self.verifyAndProcessValue( characters.count - 1 , added : c )
    }
    
    // MARK: Private
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selectorBuffer : String.CharacterView
    private var pseudoClassStringBuffer : String.CharacterView
    private var pseudoClass : PseudoClass = .Normal
    private var selectorType : SelectorType = .NXSSClass
    private var parseState : ParseState = .SelectorType
    
    private var selectorResult = ""
    
    private func verifyAndProcessValue( index : Int , added c : Character ) -> CPAppendResult {
        switch parseState {
        case .SelectorType:
            if c == "{" {
                return finalize()
            } else if c == "." {
                selectorType = .NXSSClass
                parseState = .Selector
            } else {
                selectorType = .UIKitElement
                parseState = .Selector
                return verifyAndProcessValue(index, added: c)
            }
        case .Selector:
            if c == "{" {
                return finalize()
            } else if c == ":" {
                parseState = .PseudoClass
//            } else if c == " " {
                // handles space b/t selector name and open parenthesis
            } else {
                selectorBuffer.append(c)
            }
            
        case .PseudoClass:
            if c == "{" {
                return finalize()
//            } else if c == " " {
                // space in before and after pseudoClass.
            } else {
                pseudoClassStringBuffer.append(c)
            }
        }
        return .InProgress
        
    }
    
    private func finalize() -> CPAppendResult {
        // End of command. Let's process.

        let pseudoClassStringResult = String(pseudoClassStringBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if pseudoClassStringResult.characters.count > 0 {
            if let pc = PseudoClass(rawValue: pseudoClassStringResult) {
                self.pseudoClass = pc
            } else {
                return .Invalid
            }
        }
        
        selectorResult = String(selectorBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if selectorResult.characters.count == 0 {
            return .Invalid
        }
        
        return .Resolved
    }
    
}

class CPResultMixinHeader:_CPResultBaseHeader , CPResultTypeResolvable {
    
    override init() {
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
        self.selectorBuffer = createCharacterView()
        self.currentArgumentBuffer = createCharacterView()
        super.init()
    }
    
    func resolveType() -> CPResultType {
        return .MixinHeader(selector:selectorResult, argumentNames:argumentNamesResult)
    }
 
    // MARK: Override
    
    /** Solves "@mixin foo($a,$b) {" */
    private override func characterAppended(c: Character) -> CPAppendResult {
        
        if characters.count <= keyword.count {
            
            if c == keyword[characters.count-1] {
                return .InProgress
            }
            else {
                return .Invalid
            }
            
            
        } else if argumentParseState == .Pre {
            if c == "("  {
                argumentParseState = .In
//            } else if c == " " {
                // handles space b/t selector name and open parenthesis
            } else {
                selectorBuffer.append(c)
            }
            
        } else if argumentParseState == .In  {
            
//            if c == " " {
//                
//            } else
                if c == "," {
                
                argumentNamesBuffer.append(currentArgumentBuffer)
                currentArgumentBuffer = createCharacterView()
                
            } else if c == ")" {
                
                argumentNamesBuffer.append(currentArgumentBuffer)
                currentArgumentBuffer = createCharacterView()
                argumentParseState = .Post
                
            } else {
                
                currentArgumentBuffer.append(c)
                
            }
            
        } else if c == "{" {
            if argumentParseState == .Pre || argumentParseState == .Post {
                selectorResult = String(selectorBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                argumentNamesResult = argumentNamesBuffer.map({ buffer in
                    return String(buffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                })
                return .Resolved
            } else {
                return .Invalid
            }
        }
        
        return .InProgress
        
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    private var currentArgumentBuffer : String.CharacterView
    private var argumentNamesBuffer : [String.CharacterView] = []
    private var selectorBuffer : String.CharacterView
    private var keyword : [Character] = []
    
    private var selectorResult = ""
    private var argumentNamesResult : [String] = []
}

class CPResultBlockClosure:_CPResultBase , CPResultTypeResolvable  {

    func resolveType() -> CPResultType {
        return .BlockClosure
    }
    
    // MARK: Override
    
    /** Solves end of block/rule-set "}" */
    private override func characterAppended(c: Character) -> CPAppendResult {
        if characters.count == 1 && c == "}" {
            return .Resolved
        } else {
            return .Invalid
        }
    }
}