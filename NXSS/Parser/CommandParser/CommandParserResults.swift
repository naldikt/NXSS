//
//  CommandParserResults.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/28/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

let CPBufferInitialLength : Int = 30

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

class _CPResultBase {
    
    // MARK: Private 
    
    private var characters : [Character] = []
    
    private func createCharacterView() -> String.CharacterView {
        var ret = String.CharacterView()
        ret.reserveCapacity(CPBufferInitialLength)
        return ret
    }
    
    private func createCharacterView(initialCharacter : Character) -> String.CharacterView {
        var ret = createCharacterView()
        ret.append(initialCharacter)
        return ret
    }
}

/*! Base class for reserved-key and value pair line. You need to subclass me. */
class _CPResultReservedKeyValueBase : _CPResultBase, CPAppendable {
    
    /** Anything after key is considered value. */
    init(key : String) {
        var k : [Character] = []
        for character in key.characters {
            k.append(character)
        }
        self.key = k
    }
    
    func append(c:Character) -> CPAppendResult {
        characters.append(c)
        return verify(characters.count-1, added : c)
    }
    
    // MARK: Private
    
    private var key : [Character]
    private var value : String = ""
    
    private func verify( index : Int , added c : Character ) -> CPAppendResult {
        if characters.count <= key.count {
            return verifyKey( index , added : c )
        } else {
            let result = verifyValue( index, added : c )
            switch result {
            case .InProgress:
                self.processValue( index,added:c)
            case .Resolved:
                if value.characters.count == 0 {
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
            if value.characters.count == 0 {
                return .Invalid
            }
            return .Resolved
            
        } else if c == " " {
            return .InProgress // skip
            
        } else {
            value.append(c)
            return .InProgress
        }

    }
    
    private func processValue( index:Int, added c : Character ) {
        // Nothing, please override and do anything you'd like.
    }
}

class CPResultExtend : _CPResultReservedKeyValueBase , CPResultTypeResolvable {
    
    /** "@extend .Foo:normal" or "@extend UIView:selected" */
    init() {
        super.init(key: "@extend ")
    }
    
    func resolveType() -> CPResultType {
        return .Extend(selector:selector, selectorType:selectorType, pseudoClass:pseudoClass)
    }
    
    // MARK: Private
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selector = ""
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
        super.init(key: "@include ")
    }
    
    func resolveType() -> CPResultType {
        return .Include(selector:selector, argumentValues : argumentValues)
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    private var currentArgument  = ""
    private var selector  = ""
    private var argumentValues:[String] = []
    private var numOfParenthesis = 0  // helps with distinguishing between arg and sub-arg
 
    private override func processValue(index : Int , added c : Character) {
        if c  == " " { return }
        
        switch argumentParseState {
        case .Pre:
            if c == "(" {
                argumentParseState = .In
            } else  {
                selector.append(c)
            }
            
        case .In:
            
            if c == "(" {
                numOfParenthesis += 1
            } else if c == ")" {
                numOfParenthesis -= 1
            }
            
            if c == ")" {
                argumentParseState = .Post
                
            } else if c  == "," && numOfParenthesis == 0 {
                argumentValues.append(currentArgument)
                currentArgument = ""

            } else {
                currentArgument.append(c)
                
            }
            
        case .Post:
            break
        }
    }
}

class CPResultImport : _CPResultReservedKeyValueBase, CPResultTypeResolvable {
    
    /*!  "@import FileName;*/
    init() {
        super.init(key: "@import ")
    }
    
    func resolveType() -> CPResultType {
        return .Import(fileName:value)
    }
}

class CPResultStyleDeclaration : _CPResultBase , CPAppendable, CPResultTypeResolvable {
    
    /*! Parses standard key-value style declaration e.g. "background-color: red;" */
    func append(c:Character) -> CPAppendResult {
        
        characters.append(c)
        
        if c != " " {
            switch parseState {
            case .Key:
                if c  == ":" {
                    parseState = .Value
                } else {
                    key.append(c)
                }
            case .Value:
                if c == ";" {
                    if key.characters.count > 0 && value.characters.count > 0 {
                        return .Resolved
                    } else {
                        return .Invalid
                    }
                } else {
                    value.append(c)
                }
            }
        }
        
        return .InProgress
    }
    
    func resolveType() -> CPResultType {
        return .StyleDeclaration(key:key,value:value)
    }
    
    // MARK: Private
    
    private enum ParseState {
        case Key
        case Value
    }
    
    private var key = ""
    private var value = ""
    private var parseState : ParseState = .Key
}

class _CPResultBaseHeader : _CPResultBase {
    
}

class CPResultRuleSetHeader : _CPResultBaseHeader, CPAppendable , CPResultTypeResolvable {
    
    /*! Parses UIKitElement header e.g.  "UIButton:normal {" */
    func append(c:Character) -> CPAppendResult {
        characters.append(c)
        return self.verifyAndProcessValue( characters.count - 1 , added : c )
    }
    
    func resolveType() -> CPResultType {
        return .RuleSetHeader(selector:selector, selectorType:.UIKitElement, pseudoClass:pseudoClass)
    }
    
    // MARK: Private
    
    private enum ParseState {
        case SelectorType
        case Selector
        case PseudoClass
    }
    
    private var selector : String = ""
    private var pseudoClassString : String = ""
    private var pseudoClass : PseudoClass = .Normal
    private var selectorType : SelectorType = .NXSSClass
    private var parseState : ParseState = .SelectorType
    
    private func verifyAndProcessValue( index : Int , added c : Character ) -> CPAppendResult {
        if c != " " {
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
                } else {
                    selector.append(c)
                }
                
            case .PseudoClass:
                if c == "{" {
                    return finalize()
                } else {
                    pseudoClassString.append(c)
                }
            }
        }
        return .InProgress
        
    }
    
    private func finalize() -> CPAppendResult {
        // End of command. Let's process.
        if selector.characters.count == 0 {
            return .Invalid
        }
        if pseudoClassString.characters.count > 0 {
            if let pc = PseudoClass(rawValue: pseudoClassString) {
                self.pseudoClass = pc
            } else {
                return .Invalid
            }
        }
        return .Resolved
    }
    
}

class CPResultMixinHeader:_CPResultBaseHeader, CPAppendable , CPResultTypeResolvable {
    
    override init() {
        let key = "@mixin "
        var keyword : [Character] = []
        for k in key.characters {
            keyword.append(k)
        }
        self.keyword = keyword
        super.init()
    }

    /** Solves "@mixin foo($a,$b) {" */
    func append(c: Character) -> CPAppendResult {
        characters.append(c)
        
        if characters.count < keyword.count {

            if c == keyword[characters.count-1] { return .InProgress }
            else { return .Invalid }
            

        } else if argumentParseState == .Pre {
            if c == "("  {
                argumentParseState = .In
            } else {
                if selector == nil { selector = "" }
                selector!.append(c)
            }
            
        } else if argumentParseState == .In  {
            
            if c == " " {
                
            } else if c == "," {
                
                argumentNames.append(currentArgument)
                currentArgument = ""
                
            } else if c == ")" {
                
                argumentNames.append(currentArgument)
                currentArgument = ""
                argumentParseState = .Post
                
            } else {
            
                currentArgument.append(c)
                
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
    
    func resolveType() -> CPResultType {
        return .MixinHeader(result:self)
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    private var currentArgument : String = ""
    private let keyword : [Character]
    private var argumentNames : [String] = []
    private var selector : String?
    
    private override func verifyValue( index : Int , added c : Character ) -> CPAppendResult {
        let result = super.verifyValue(index, added: c)
        self.interceptVerifyValue(index,added:c)
        if result == .Resolved && argumentParseState == .In {
            // Something is wrong. Parse state should have been either .Pre or .Post
            return .Invalid
        } else if result == .Resolved {
            if argumentNames == nil { argumentNames = [] }
        }
        return result
    }
    
    private func interceptVerifyValue(index : Int , added c : Character) {
        if argumentParseState == .Pre && c == "(" {
            argumentNames = []
            argumentParseState = .In
            
        } else if argumentParseState == .Pre && c != " " {
        
            if selector == nil { selector = "" }
            selector?.append(c)
            
            
        } else if argumentParseState == .In && c == ")" {
            argumentParseState = .Post
            
        } else if argumentParseState == .In && c == "," {
            argumentNames?.append(currentArgument)
            currentArgument = ""
        
        } else if argumentParseState == .In {
            if c != " " {
                currentArgument.append(c)
            }
        }
    }
}