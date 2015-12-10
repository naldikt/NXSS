//
//  RuleSetBlock.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/27/15.
//  Copyright © 2015 Rhapsody. All rights reserved.
//

import Foundation


class RuleSetBlock : Block {

    private(set) var pseudoClass : PseudoClass
    private let selectorType : SelectorType
    
    init( selector:String  , selectorType : SelectorType , pseudoClass:PseudoClass ,  parentBlock:Block? = nil ) {
        self.pseudoClass = pseudoClass
        self.selectorType = selectorType
        super.init(selector:selector,parentBlock:parentBlock)
    }
     
    
    /**
        Turn this into a RuleSet
    */
    func compile() throws  -> CompiledRuleSet {
        let ret = CompiledRuleSet(selector:selector!,selectorType:selectorType,pseudoClass:pseudoClass,declarations:try resolveDeclarations())
        return ret
    }
    
}