//
//  RuleSetScope.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/27/15.
//  Copyright © 2015 Rhapsody. All rights reserved.
//

import Foundation


class RuleSetScope : Scope {

    private(set) var pseudoClass : PseudoClass
    private let selectorType : SelectorType
    
    init( selector:String  , selectorType : SelectorType , pseudoClass:PseudoClass ,  parentScope:Scope? = nil ) {
        self.pseudoClass = pseudoClass
        self.selectorType = selectorType
        super.init(selector:selector,parentScope:parentScope)
    }
     
    
    /**
        Turn this into a RuleSet
    */
    func compile() throws  -> CompiledRuleSet {
        let ret = CompiledRuleSet(selector:selector!,selectorType:selectorType,pseudoClass:pseudoClass,declarations:try resolveDeclarations())
        return ret
    }
    
}