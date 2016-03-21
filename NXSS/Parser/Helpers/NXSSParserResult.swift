//
//  NXSSParserResult
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 3/20/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

internal class NXSSParserResult : ParserResult {
    
    private(set) var ruleSets : [String:CompiledRuleSet] = Dictionary()
    private(set) var variables : Declarations = Dictionary()
    private(set) var mixins : [String:CompiledMixin] = Dictionary()

    // Default construct
    init() {}
    
    // Initialize self from the given parserresult.
    convenience init(parserResult:ParserResult) {
        self.init()
        self.mergeFrom(parserResult)
    }

    
    func addMixin( styleMixin : CompiledMixin ) {
        self.mixins[styleMixin.selector] = styleMixin
    }
    
    func addRuleSet( styleClass : CompiledRuleSet ) {
        self.ruleSets[styleClass.compiledKey] = styleClass
    }
    
    func addVariables( variables : Declarations ) {
        for (key,val) in variables {
            self.variables[key] = val
        }
    }
    
    /** Merge another parser result to self. Any new value will override self. */
    func mergeFrom( parserResult : ParserResult ) {
        for (key,value) in parserResult.ruleSets {
            self.ruleSets[key] = value
        }
        for (key,value) in parserResult.variables {
            self.variables[key] = value
        }
        for (key,value) in parserResult.mixins {
            self.mixins[key] = value
        }
    }
    

}