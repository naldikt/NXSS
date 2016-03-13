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
    
    private(set) var value : String?
    
    func append(c:Character) -> CPAppendResult {
        characters.append(c)
        return verify(characters.count-1, added : c)
    }
    
    // MARK: Private
    
    private var key : [Character]
    private var valueBuffer : String.CharacterView?
    
    private func verify( index : Int , added c : Character ) -> CPAppendResult {
        if characters.count <= key.count {
            return verifyKey( index , added : c )
        } else {
            return verifyValue( index, added : c )
        }
    }
    
    private func verifyKey( index : Int , added c : Character ) -> CPAppendResult {
        if key[index] == c { return .InProgress }
        else { return .Invalid }
    }
    
    private func verifyValue( index : Int , added c : Character ) -> CPAppendResult {
        if valueBuffer == nil {
            valueBuffer = String.CharacterView()
            valueBuffer?.reserveCapacity(CPBufferInitialLength)
        }
        
        if c == ";" {
            guard let valueBuffer = valueBuffer else {
                return .Invalid
            }
            value = String(valueBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            return .Resolved
            
        } else if valueBuffer != nil {
            
            valueBuffer?.append(c)
            return .InProgress
            
        } else {
            
            valueBuffer = createCharacterView(c)
            return .InProgress
            
        }

    }
}

class CPResultExtend : _CPResultReservedKeyValueBase , CPResultTypeResolvable {
    
    init() {
        super.init(key: "extend ")
    }
    
    func resolveType() -> CPResultType {
        return .Extend(result:self)
    }
    
}


class CPResultInclude : _CPResultReservedKeyValueBase , CPResultTypeResolvable {
    
    /* Non-nil when resolved */
    private(set) var selector:String?
    private(set) var argumentNames:[String]?
    
    init() {
        super.init(key: "@include ")
    }
    
    func resolveType() -> CPResultType {
        return .Include(result:self)
    }
    
    // MARK: Private
    
    private var argumentParseState : CPResultArgParseState = .Pre
    private var currentArgument : String = ""
    
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

class CPResultImport : _CPResultReservedKeyValueBase, CPResultTypeResolvable {
    
    init() {
        super.init(key: "@import ")
    }
    
    func resolveType() -> CPResultType {
        return .Import(result:self)
    }
}

class CPResultStyleDeclaration : _CPResultBase , CPAppendable, CPResultTypeResolvable {

    private(set) var key : String?
    private(set) var value : String?
    
    /*! Parses standard key-value style declaration e.g. "background-color: red;" */
    func append(c:Character) -> CPAppendResult {
        characters.append(c)
        
        if c == ";" {
            guard let _ = keyBuffer, _ = valueBuffer else {
                return .Invalid
            }
            key = String(keyBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            value = String(valueBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if key!.characters.count == 0 || value!.characters.count == 0 {
                return .Invalid
            }
            return .Resolved
            
        } else if keyBuffer == nil {
            
            keyBuffer = createCharacterView(c)
            return .InProgress
            
        } else if keyBuffer != nil {
            
            if c == ":" {
                
                valueBuffer = createCharacterView()
                return .InProgress
                
            } else {
                
                keyBuffer?.append(c)
                return .InProgress
            }
            
        } else {
            return .Invalid
        }
        
    }
    
    func resolveType() -> CPResultType {
        return .StyleDeclaration(result:self)
    }
    
    // MARK: Private
    
    private var keyBuffer : String.CharacterView?
    private var valueBuffer : String.CharacterView?
    
}

class _CPResultBaseHeader : _CPResultBase {
    
}

class CPResultUIKitElementHeader : _CPResultBaseHeader, CPAppendable , CPResultTypeResolvable {
    
    private(set) var selector : String?  // the Name
    private(set) var pseudoClass : PseudoClass?
    
    /*! Parses UIKitElement header e.g.  "UIButton {" */
    func append(c:Character) -> CPAppendResult {
        characters.append(c)
        
        if c == "{" {
            
            guard let _ = selectorBuffer else {
                return .Invalid
            }
            selector = String(selectorBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if let pseudoClassBuffer = pseudoClassBuffer {
                let str = String(pseudoClassBuffer).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if let pc = PseudoClass(rawValue:str) {
                    pseudoClass = pc
                } else {
                    return .Invalid
                }
            }
            return .Resolved
            
        } else if selectorBuffer == nil {
            
            selectorBuffer = createCharacterView(c)
            return .InProgress
            
        } else if pseudoClassBuffer != nil {
            
            pseudoClassBuffer?.append(c)
            return .InProgress
        
        } else if selectorBuffer != nil {
            
            if c == ":" {
                
                pseudoClassBuffer = createCharacterView()
                return .InProgress
                
            } else {
                
                selectorBuffer?.append(c)
                return .InProgress
            }
            
        } else {
            return .Invalid
        }
    }
    
    func resolveType() -> CPResultType {
        return .UIKitElementHeader(result:self)
    }
    
    // MARK: Private
    
    // - do we even need this? seems overkill... usually selector & pseudoClass are < 10 characters
    private var selectorBuffer : String.CharacterView?
    private var pseudoClassBuffer : String.CharacterView?
}

class CPResultNXSSClassHeader : CPResultUIKitElementHeader {
    
    /** nxss-class is the same as uikit class but starts with "." */
    override func append( c : Character ) -> CPAppendResult {
        if characters.count == 0 && c == "." {
            return super.append(c)
        } else {
            return .Invalid
        }
    }
    
    override func resolveType() -> CPResultType {
        return .NXSSClassHeader(result:self)
    }
}


class CPResultMixinHeader:_CPResultBaseHeader, CPAppendable , CPResultTypeResolvable {
    
    /* non-nil when Resolved. */
    private(set) var argumentNames : [String] = []
    private(set) var selector : String?
    
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