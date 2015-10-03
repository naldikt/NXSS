//
//  Parser.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/22/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

class Parser {

	init( stringQueue : StringQueue ) {
		self.stringQueue = stringQueue
		contextQueue.push(Context())
	}

	/**
		Parses the input string.
		:return:	dictionary
				String => Name of the style class.
				StyleClass => Parsed, compiled entries.
	*/
	func parse() throws -> [String:StyleClass] {
        do {
            
            let ret = try traverse()
            return ret
            
        } catch let error as ParseError {
            
            switch error {
            case .Unexpected(let msg):
                NSLog("-------------------")
                NSLog("NXSS: Parsing error encountered.")
                NSLog("\(msg)")
                NSLog("-------------------")
            }
            throw error
            
        } catch let error {
            
            NSLog("[ERROR] Unknown: \(error)")
            throw error
        }

	}
    
    // MARK: - Private
    
    let stringQueue : StringQueue
    
    private var mixins : [String:StyleMixin] = Dictionary()		// mixinName => StyleMixin
    
    
    // MARK: - State Machine
    
    private let contextQueue : Queue<Context> = Queue()
    
    private func traverse() throws -> [String:StyleClass] {
    
    	var styleClasses : [String:StyleClass] = Dictionary()  // ret val
    	var curBuffer : String = ""
    
    	while stringQueue.hasNext() {
    		let s = stringQueue.pop()

    		// Start of Context
    		if s == "{" {
    		
    			// Figure out whether what kind of header this is
                curBuffer = curBuffer.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    			let headerType = try HeaderType.parse(curBuffer)
    			
    			switch headerType {

					case .StyleMixin:
					
                        let ss = curBuffer.stringByRemovingFirstOccurenceOfString("@mixin")
						let (name,argNames) = try Parser.parseNameAndArgs( ss )
                        
						contextQueue.push(
                            MixinContext(name:name,argNames:argNames,parentContext:contextQueue.peek())
                        )
						
					case .StyleClass:
                        
    					contextQueue.push(
                            ClassContext(name:curBuffer,parentContext:contextQueue.peek())
                        )
    			}
    		
    			curBuffer = ""
    			
    			
    		// End of Context
    		} else if s == "}" {
    		
    			curBuffer = curBuffer.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    			if curBuffer.characters.count > 0 {
    				assert(false,"You forgot to apply semi-colon to your last line.")
    			}
    			// By now curBuffer is an empty string
    		
    			let oldContext = contextQueue.pop()
    			if let oldContext = oldContext as? MixinContext {
    				
    				let styleMixin : StyleMixin = oldContext.compile()
    				mixins[styleMixin.name] = styleMixin
    				
    			
    			} else if let oldContext = oldContext as? ClassContext {
    			
    				let styleClass : StyleClass = oldContext.compile()
    				styleClasses[styleClass.name] = styleClass
    			
                } else {
                    assert(false,"Should not have gone here.")
                }
    			
    			
    		}	 
    		   		
    		// End of Line
    		else if s == ";" {
    			
    			let (type,key,value) = try KeyValueParser.parse( curBuffer )
    			
    			
    			let curContext = contextQueue.peek()
    			switch type {
    				case .Entry:
                        
    					curContext.addEntry(key,value: value)
                    
    				case .Variable:
                        
    					curContext.addVariable(key,value: value)
                    
    				case .Include:
                        
    					// Let's find the mixin
                        let ss = value.stringByReplacingOccurrencesOfString("@include", withString: "")
    					let (name,argVals) = try Parser.parseNameAndArgs( ss )
                        
                        guard let mixin = mixins[name] else {
                            assert(false,"Unknown mixin name: \(name)")
                        }
                        
    					let entries : [String:String] = mixin.compile(argVals)
    					curContext.addEntries(entries)
    					
    			}
    		
    			curBuffer = ""
    			
            } else {
                
                curBuffer += s
            }
    		
    	
    	}
    	
    	return styleClasses
    
    }
    
    
    /**
    	:param:		string		i.e. "foo(a,b,3)"
    	
    	:return:

            Input           "foo(a,b,3)"
    		Output.name		"foo"
    		Output.args		["a","b","3"]
    
            Input           "foo"
            Output.name     "foo"
            Output.args     []
    */
    private class func parseNameAndArgs(string:String) throws  -> (name:String,args:[String]) {
    
    	var buf = ""
        var name : String?
    	var args : [String] = []
    	
    	let inputQueue = StringQueue(string: string)
    	
        while inputQueue.hasNext() {
			let s = inputQueue.pop()
            
    		if s == "(" {
                
    			name = buf
    			buf = ""
    			
    		} else if s == ")" {
    		
    			assert(inputQueue.hasNext() == false, "There should not be anymore character after this.")
    			args = buf.componentsSeparatedByString(",")
    			break
    		
    		} else {
                
    			buf += s
                
    		}
    	}
        
        if buf.characters.count > 0 && name == nil {
            name = buf
        }
        
        if let name = name  {
            return (name:name,args:args)
        } else {
            var msg = "This line does not fulfill header requirement (i.e. \"foo(a,b,3)\"):\n"
            msg += string
            throw ParseError.Unexpected(msg: msg)
        }
    }
}