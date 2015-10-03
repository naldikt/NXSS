//
//  MixinContext.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/27/15.
//  Copyright © 2015 Rhapsody. All rights reserved.
//

import Foundation

class MixinContext : Context {
    
    let argNames : [String]
    
    init( name:String , argNames : [String] , parentContext : Context? = nil ) {
        self.argNames = argNames
        super.init( name : name , parentContext: parentContext )
    }
    
    /**
        Turn this into a StyleMixin.
    */
    func compile() -> StyleMixin {
        let ret = StyleMixin(name:name!,argNames:argNames,entries:resolveEntries())
        return ret
    }
}