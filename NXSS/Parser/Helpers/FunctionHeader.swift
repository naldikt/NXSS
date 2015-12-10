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
        
        var buf = ""
        var name : String?   // e.g. ".foo:selected"
        var args : [String] = []
        
        let inputQueue = StringQueue(string: input)
        var numParenthesis : Int = 0
        
        while inputQueue.hasNext() {
            let s = inputQueue.pop()
            
            if s == "(" {
                
                if numParenthesis == 0 {
                    // First opening parenthesis! buf is the name.
                    name = buf
                    buf = ""
                } else {
                    // This is opening parentesis of an arg. Let's just append to buf.
                    buf += s
                }
                numParenthesis++
                
            } else if s == ")" {
                
                numParenthesis--
                if numParenthesis == 0 {
                    // We're back to normal. Let's bail.
                    if buf != "" {
                        // This is to handle case e.g. "foo()"
                        args.append(buf)
                        buf = ""
                    }
                    break
                    
                } else {
                    // This is close parenthesis of an arg. Let's just append to buf
                    buf += s
                }
                
            } else if s == "," {
                
                assert( numParenthesis > 0 , "There should not be a comma before first open parenthesis or after last close parenthesis.")
                if numParenthesis == 1 {
                    // We know this is a real arg
                    args.append(buf)
                    buf = ""
                } else {
                    // Okay this is part of an arg. Let's just append to buf
                    buf += s
                }
                
            } else {
                
                buf += s
                
            }
        }
        
        if buf.characters.count > 0 && name == nil {
            name = buf
        }
        
        args = args.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
        
        if let name = name?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            
            return (name:name,args:args)
            
        } else {
            
            throw NXSSError.Parse(msg: "FunctionHeader failed to parse because there is no name", statement: input, line:nil)
            
        }


    }
}