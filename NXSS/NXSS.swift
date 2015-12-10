//
//  NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

public typealias FilePath = String


public class NXSS {
    
    /** Shared Instance */
    public static var sharedInstance : NXSS {
        dispatch_once(&NXSS.initToken) {
            NXSS._instance = NXSS()
        }
        return _instance!
    }
    
    /**
        Start NXSS.
        Parse the file with the given name and the bundle they're in.
    */
    public func useFile( fileName : String , bundle : NSBundle? = nil ) {
        let parser = Parser(fileName:fileName, bundle:bundle)
        self.ruleSets = try! parser.parse()
    }
    

    
    /**
        Get the declarations.
    */
    public func getStyleDeclarations( selector : String, selectorType: SelectorType, pseudoClass:PseudoClass? = .Normal ) -> Declarations? {
        return getStyleRuleSet(selector, selectorType: selectorType, pseudoClass:pseudoClass)?.declarations
    }
    
    /**
        Get the final rule set.
    */
    public func getStyleRuleSet(  selector : String, selectorType: SelectorType, pseudoClass:PseudoClass? =  .Normal ) -> CompiledRuleSet? {
        let pseudoCls = pseudoClass ?? .Normal
        
        let passedArgKey = CompiledRuleSet.getCompiledKey( selector , selectorType:  selectorType, pseudoClass:  pseudoCls )
        if let ruleSet = ruleSets[passedArgKey] {
            
            // We'll need to see if .Normal is available
            if pseudoCls != .Normal {
                let normalKey = CompiledRuleSet.getCompiledKey( selector , selectorType:  selectorType, pseudoClass:  .Normal )
                if let normalRuleSet = ruleSets[normalKey] {
                    ruleSet.mergeDeclarationsFrom(normalRuleSet.declarations, overrideSelf: false)
                }
            }
            
            return ruleSet
            
        } else {
            
            // What we want doesn't exist
            return nil
        }
    }
    
    
    // MARK: - Private
    
    private static var initToken = dispatch_once_t()
    private static var _instance : NXSS?
    
    private var ruleSets: [String:CompiledRuleSet] = Dictionary()
    
    init () {
        Swizzler.swizzle()
    }
    
    // MARK: - Unit Tests
    
    /**
        This is used for Unit Tests Only.
        See if the styleClasses retrieved from parsing (useFile()) is same content-wise as the target.
        -   parameters:
            -   targetRuleSets      Self-made dictionary (result) to compare to. This should contain only end results, and not any mixin.
    */
    internal func isEqualRuleSets( targetRuleSets : [String:[String:String]] ) throws -> Bool {
        
        if ruleSets.count != targetRuleSets.count {
            NSLog("NXSS.isStyleClassEqualToDictionary failed because self.count [\(ruleSets.count)] is not same as target.count [\(targetRuleSets.count)]")
            return false
        }
        
        for (blockHeaderString,declarations) in targetRuleSets {
            
            var selector:String?
            var selectorType:SelectorType?
            var pseudoClass:PseudoClass?
            
            switch try BlockHeader.parse(blockHeaderString) {
            case .Mixin(_,_):
                assert(false,"Should never get here. We are meant to compare with endresults only.")
                return false
                
            case .Class(let selector_, let pseudoClass_):
                selector = selector_
                pseudoClass = pseudoClass_
                selectorType = .Class
            
            case .Element(let selector_, let pseudoClass_):
                selector = selector_
                pseudoClass = pseudoClass_
                selectorType = .Element
                
            }
            
            if let selfStyleClassEntries = self.getStyleDeclarations(selector!, selectorType:selectorType!, pseudoClass: pseudoClass!){
                if !isDictionary(selfStyleClassEntries, equalsToDictionary:  declarations ) {
                    NSLog("NXSS.isStyleClassEqualToDictionary failed with comparing selector '\(selector)' selectorType '\(selectorType)' pseudoClass '\(pseudoClass)' which self= \(selfStyleClassEntries), targetDeclarations=\(declarations)")
                    return false
                }
                
            } else {
                NSLog("RuleSets \(ruleSets)")
                NSLog("NXSS.isStyleClassEqualToDictionary failed because selector \(selector) selectorType \(selectorType) pseudoClass \(pseudoClass) does not exist on self's")
            }
                
        }
        
        return true
    }
    
    private func isDictionary(dictionary : Dictionary<String,String>, equalsToDictionary targetDictionary : Dictionary<String,String> ) -> Bool {
        if dictionary.count != targetDictionary.count { return false }
        
        for (key1,val1) in dictionary {
            if let val2 = targetDictionary[key1] {
                if val1 != val2 {
                    return false
                }
            } else {
                return false
            }
            
        }
        
        return true
    }
    
    /**
        If input string is nil or empty will default to .Normal.
     */
    private func translatePseudoClass ( string : String? ) -> PseudoClass? {
        guard let s = string else {
            return .Normal
        }
        
        if s.characters.count == 0 {
            return .Normal
        }
        
        return PseudoClass(rawValue: s)
    }
    
}