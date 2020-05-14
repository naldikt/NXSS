//
//  CompiledMixin.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/22/15.
//  Copyright (c) 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation


public class CompiledMixin {
    
    /**
        The name of the mixin.
    */
    let selector : String
    
    /**
        The names of the arguments, without the dollar sign prefix.
    */
    let argNames : [String]
    
    /**
        The declarations.
    */
    let declarations : Declarations
    
    init( selector : String , argNames : [String] , declarations : Declarations ) {
        self.selector = selector
        self.argNames = argNames
        self.declarations = declarations
    }
    
    /**
        Return resolved entries with the given arg values for this mixins.
        
        Sample: Say you have mixin foo($a,$b) and you want to assign $a=1 and $b=2.
                Just pass in argValues = [1,2]
    
        - return:	declarations
    */
    func resolveArguments( argValues : [String] ) throws -> Declarations {
        
        if argValues.count != argNames.count {
            throw NXSSError.Parse(msg: "Arguments passed for calling mixin is incorrect (check the number of args).", statement: "@include \(selector)", line: nil)
        }
    
    	var ret : Declarations = Dictionary()
    	
        for (k,v) in declarations {
            if let index = argNames.indexOf(v) where v.hasPrefix("$") {
                
                let realValue = argValues[index]
                ret[k]=realValue
                
                
            } else {
                ret[k]=v
            }
        }
    	
        return ret
    }

}
