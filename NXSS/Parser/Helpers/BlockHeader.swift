//
//  BlockHeader.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/3/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

enum BlockHeader {
    case Mixin(selector:String, args:[String])
    case Class(selector:String, pseudoClass:PseudoClass)
    case Element(selector:String, pseudoClass:PseudoClass)
    
    /**
     Samples:
     
     Input  "@mixin foo(a,b,3)" => .Mixin( selector = "foo" , args = ["a","b","3"] )
     Input  "foo"                   => .Element( selector = "foo" , pseudoClass = .Normal )
     Input  "@mixin foo(a,bar(1,2),c)"     => .Mixin( selector = "foo" , args = ["a","bar(1,2)","c"] )
     Input  "foo:selected"          => .Element( selector = "foo" , pseudoClass = .Selected )
     Input  ".foo:selected"         => .Class( selector = "foo" , pseudoClass = .Selected )
     
    */
    static func parse(input:String) throws -> BlockHeader {
        
        
        // If there's "@mixin" in the front, let's get rid of that first.
        
        var isMixin = false
        
        var s = input.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if s.hasPrefix("@mixin") {
            s = s.stringByRemovingFirstOccurenceOfString("@mixin")
            isMixin = true
            
        }
        
        let (name,args) = try FunctionHeader.parse(s)
        
        if isMixin {
            
            return .Mixin(selector:name,args:args)
            
        } else if s.hasPrefix(".") {
            
            let (name,pseudoClass) = try parseSelectorAndPseudoClass(name)
            
            let cleanName = name.stringByRemovingFirstOccurenceOfString(".")
            return .Class(selector:cleanName, pseudoClass: pseudoClass)
            
        } else {
            
            let (name,pseudoClass) = try parseSelectorAndPseudoClass(name)
            
            return .Element(selector:name, pseudoClass: pseudoClass)

        }
    }
    
    /**
        Given a selector, get the PseudoClass specified in it.
        If there's no pseudoClass, will default to .Normal.
    */
    private static func parseSelectorAndPseudoClass(input:String) throws -> (selector:String,pseudoClass:PseudoClass) {
        
        var selector : String = input
        var pseudoClass : PseudoClass = .Normal
 
        if input.rangeOfString(":") != nil {
            
            let selAndPseudo = input.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let components = selAndPseudo.componentsSeparatedByString(":")
            if components.count != 2 {
                throw NXSSError.Parse(msg: "BlockHeader encounters a function name with more than 1 selector", statement: selAndPseudo, line:nil)
            }
            
            selector = components[0]

            guard let _pseudo = PseudoClass(rawValue: components[1]) else {
                throw NXSSError.Parse(msg: "Trying to parse selector but it is not known", statement: components[1], line:nil)
            }
            

            pseudoClass = _pseudo
        }
        
        return (selector:selector,pseudoClass:pseudoClass)
    }
}
