//
//  FunctionHeader.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/9/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

class FunctionHeader {
    
    /**
        Parses a function header into its name and arguments.
        `name` is anything before the start of open parentesis (if there's parenthesis).
        `args` is anything inside the paranthesis (if applicable).
     
        i.e. 
     
        "foo(1,bar(1,2),b)"
            name: foo
            args: [ "1" , "bar(1,2)" , "b" ]
     
        ".foo:selected"
            name: ".foo:selected"
            args: []
     
        "UILabel"
            name: "UILabel"
            args: []
    */
    static func parse(input:String) throws -> (name:String,args:[String]) {
        
        var curBuffer : String.CharacterView = String.CharacterView()
        curBuffer.reserveCapacity(100)
        
        var name : String?   // e.g. ".foo:selected"
        var args : [String] = []
        
        var numParenthesis : Int = 0

        for s in input.characters {
            
            if s == "(" {
                
                if numParenthesis == 0 {
                    // First opening parenthesis! buf is the name.
                    name = String(curBuffer)
                    curBuffer.removeAll(keepCapacity: true)

                } else {
                    // This is opening parentesis of an arg. Let's just append to buf.
                    curBuffer.append(s)
                }
                numParenthesis += 1
                
            } else if s == ")" {
                
                numParenthesis -= 1
                if numParenthesis == 0 {
                    // We're back to normal. Let's bail.
                    let string = String(curBuffer)
                    if string != "" {
                        // This is to handle case e.g. "foo()"
                        args.append(string)
                        curBuffer.removeAll(keepCapacity: true)
                    }
                    break
                    
                } else {
                    // This is close parenthesis of an arg. Let's just append to buf
                    curBuffer.append(s)
                }
                
            } else if s == "," {
                
                assert( numParenthesis > 0 , "There should not be a comma before first open parenthesis or after last close parenthesis.")
                if numParenthesis == 1 {
                    // We know this is a real arg
                    args.append(String(curBuffer))
                    curBuffer.removeAll(keepCapacity: true)
                } else {
                    // Okay this is part of an arg. Let's just append to buf
                    curBuffer.append(s)
                }
                
            } else {
                
                curBuffer.append(s)
                
            }
        }
        
        if curBuffer.count > 0 && name == nil {
            name = String(curBuffer)
        }
        
        args = args.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        
        if let name = name?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            
            return (name:name,args:args)
            
        } else {
            
            throw NXSSError.Parse(msg: "FunctionHeader failed to parse because there is no name", statement: input, line:nil)
            
        }


    }
}