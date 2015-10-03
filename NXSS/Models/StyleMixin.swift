//
//  Mixin.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/22/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation


class StyleMixin {
    
    /**
        The name of the mixin.
    */
    let name : String
    
    /**
        The names of the arguments, without the dollar sign prefix.
    */
    let argNames : [String]
    
    /**
        The entries.
    */
    let entries : [String:String]
    
    
    init( name : String , argNames : [String] , entries : [String:String] ) {
        self.name = name
        self.argNames = argNames
        self.entries = entries
    }
    
    /**
        Return compiled entries with the given arg values for this mixins.
        :return:	entries
    */
    func compile( argValues : [String] ) -> [String:String] {
    
    	var ret : [String:String] = Dictionary()
    	
    	
        return Dictionary()
    }

}