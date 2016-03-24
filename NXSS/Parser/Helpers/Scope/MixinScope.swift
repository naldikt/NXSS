//
//  MixinScope.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/27/15.
//  Copyright © 2015 Rhapsody. All rights reserved.
//

import Foundation

class MixinScope : Scope {
    
    let argNames : [String]
    
    /**
        - parameters:
            - argNames  The argument names, including the prefix "$" for each name.
    */
    init( selector:String , argNames : [String] , parentScope :Scope? = nil ) {
        self.argNames = argNames
        super.init( selector : selector , parentScope : parentScope  )
    }
    
    override func getDeclarationValue(key: String) -> String? {
        if let val = super.getDeclarationValue(key) {
            return val
        } else {
            
            // Not found. Let's see if it's an argument, which will be compiled later.
            if argNames.indexOf(key) != nil {
                return key
            } else {
                return nil
            }
        }
    }
    
    /**
        Turn this into a StyleMixin.
        This compilation does not resolve arguments. That's a job for StyleMixin.
    */
    func compile() throws -> CompiledMixin {
        let ret = CompiledMixin(selector:selector!,argNames:argNames,declarations:try resolveDeclarations())
        return ret
    }
}