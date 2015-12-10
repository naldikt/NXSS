//
//  KeyValueParser.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/22/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

enum KeyValueType {
	case Declaration                   //	key => value is "background-color" => "red"
	case VariableDeclaration           //	key => value is "$varName" => "rgb(255,255,255,1)"
	case Include                        //  key => value is "@include" => "...". Always includes mixin.
    case Extend(selectorType:SelectorType)     //  key => value is  "@extend" => "...". Can extend any rule set.
}

class KeyValueParser {
    
    /**
    	Parse a line to key value pair.
    
        - returns:
            - type
            - key       The key. e.g. "background-color:red" has key=background-color, value=red
            - value     The key. e.g. "background-color:red" has key=background-color, value=red
    */
    class func parse( string : String ) throws -> (type:KeyValueType , key:String , value:String) {
        
        var s = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if s[0] == "$" {
            
            let (k,v) = try parseKeyVal(s)
            return (.VariableDeclaration,k,v)
            
        } else if s.hasPrefix("@include") {
        
            
            // We're going to add a faux ":" so the logic below can work.
            s.insert(":", atIndex: "@include".endIndex)
            let (k,v) = try parseKeyVal(s)
            return (.Include,k,v)
            
        } else if s.hasPrefix("@extend") {
            
            // We're going to add a faux ":" so the logic below can work.
            s.insert(":", atIndex: "@extend".endIndex)
            let (k,v) = try parseKeyVal(s)
            
            if v.hasPrefix(".") {
                return (.Extend(selectorType:.Class),k,v)
            } else {
                return (.Extend(selectorType:.Element),k,v)
            }
            
        } else {
            
            let (k,v) = try parseKeyVal(s)
            return (.Declaration,k,v)
        }
        
    }
    
    private class func parseKeyVal( string : String ) throws -> (key:String,val:String) {
        var key:String = ""
        var val:String = ""
        
        let components = string.componentsSeparatedByString(":")
        if components.count == 2  {
            
            key = components[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            val = components[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
        } else {
            
            var msg = "This line expects a key-value pair separated by a colon:\n"
            msg += string
            throw  NXSSError.Parse(msg: "KeyValueParser unable to parse", statement :string, line:nil)
        }
        
        return (key,val)
    }
}