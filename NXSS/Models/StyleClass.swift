//
//  StyleClass.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/20/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation


/**
    A context is a block specified in nxss file which starts with open parenthesis and ends with close parenthesis.
*/
class StyleClass {
    
    /**
        The name of the context.
    
        :discussion:
        The name does NOT include any type indicator such as dots (.) or pounds (#).
    */
    let name : String
    
    
    /**
        Key-value mapping of the entries specified in this context.
    */
    private(set) var entries : [String:String]

    
    /**
        :param: body       The body of the class to parse.
    */
    init( name : String , entries : [String:String] ) {
        self.name = name
        self.entries = entries
    }
    
    /**
        Include the otherEntries to current entries.
        If otherEntries contain an existing property declared in current entries, it won't override.
    */
    func include( otherEntries : [String:String] ) {
        var newEntries : [String:String] = otherEntries
        for (key,val) in entries {
            newEntries[key] = val
        }
        entries = newEntries
    }

}