//
//  CompiledRuleSet.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/20/15.
//  Copyright (c) 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

public class CompiledRuleSet : Equatable, CustomStringConvertible {
    
    /** The name of the context, does NOT include any type indicator such as dots (.) or pounds (#). */
    public let selector : String
    
    /** Indicates the kind of selector. */
    public let selectorType : SelectorType
    
    /** The pseudoClass. Defaults to Normal. */
    public let pseudoClass : PseudoClass
    
    /** Key-value mapping of the declarations specified in this context. */
    public private(set) var declarations : Declarations
    
    
    init( selector : String , selectorType : SelectorType,  pseudoClass:PseudoClass, declarations : [String:String] ) {
        self.selector = selector
        self.selectorType = selectorType
        self.pseudoClass = pseudoClass
        self.declarations = declarations
    }
    

    public var description : String {
        var s = "[StyleClass selector=\(selector) selectorType=\(selectorType)"
        
        if declarations.count > 0 {
            s += " declarations=\n"
            
            for (k,v) in declarations {
                s += "  \(k) => \(v)\n"
            }
        }
        
        s += "]\n"
        return s
    }
    
    // MARK: - Internal
    
    /**
        Take the declarations from target and make it override self's.
    
        - parameters:
            - targetdeclarations
            - overrideSelf      IF true, targetdeclarations will override self's.
                                IF false, won't override exisiting key/value pair.
    */
    internal func mergeDeclarationsFrom( targetDeclarations : Declarations , overrideSelf : Bool ) {
        for (tKey,tVal) in targetDeclarations {
            if !overrideSelf && declarations[tKey] != nil {
                continue
            }
            declarations[tKey] = tVal
        }
    }
    
    internal var compiledKey : String {
        return CompiledRuleSet.getCompiledKey( selector, selectorType:  selectorType , pseudoClass:  pseudoClass )
    }
    
    /**
        Get compiled key for dictionary key which saves this class.
        This can be anything as long as it's unique.
    */
    internal class func getCompiledKey( selector : String , selectorType : SelectorType, pseudoClass : PseudoClass ) -> String {
        return (selectorType == .NXSSClass ? "." : "") + selector + ":" + pseudoClass.rawValue
    }
    
}

/** Checks for equality in selector, type, pseudoClass, and declarations. Order of declarations do not matter. */
public func ==( style1 : CompiledRuleSet , style2 : CompiledRuleSet ) -> Bool {
    let declarations1 = style1.declarations
    let declarations2 = style2.declarations
    
    if style1.selector != style2.selector {
        return false
    } else if style1.selectorType != style2.selectorType {
        return false
    } else if style1.pseudoClass != style2.pseudoClass {
        return false
    } else if declarations1.count != declarations2.count {
        return false
    }
    
    for (k,v) in declarations1 {
        if let v2 = declarations2[k] where v == v2 {
            // We're good.
        } else {
            return false
        }
    }
    
    return true
}
 
