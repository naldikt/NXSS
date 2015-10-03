//
//  KeyValueParser.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/22/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

enum KeyValueType {
	case Entry		//	"background-color" => "red"
	case Variable	//	"$varName" => "rgb(255,255,255,1)"
	case Include    //  "@include" => "..."
}

class KeyValueParser {
    
    /**
    	Parse a line to key value pair.
    */
    class func parse( string : String ) throws -> (type:KeyValueType , key:String , value:String) {
        
        let s = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var type : KeyValueType = .Entry
        if s[0] == "$" {
        	type = .Variable
        } else if s[0] == "@" {
        	type = .Include
        }
        
        var key:String = ""
        var val:String = ""
        
        let components = s.componentsSeparatedByString(":")
        if components.count == 2  {
            
            key = components[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            val = components[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
        } else {
            var msg = "This line expects a key-value pair separated by a colon:\n"
            msg += s
            throw ParseError.Unexpected(msg: msg)
        }
        
        return (type,key,val)
    }
}