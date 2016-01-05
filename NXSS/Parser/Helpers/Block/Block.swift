//
//  Block.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/26/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

/**
    Block is used during parsing.
    The main block (root, top-most) does not have any selector.


    i.e. Say a file consists of:
    """
    // current block is nil (main)

    foo {
        // current block is ClassBlock foo
        // its parent is Main
    }


    @mixin bar ($a) {
        // current block is MixinBlock bar
        // its parent is Main
    }

    """
*/
class Block {

	let selector : String?

    /**
        - parameters:
            - selector          The selector/selector of the block. nil means it's a root block.
            - parentBlcok       It is used for lookup. Say you're in some ClassBlock which refers to a property not in that block. With parentBlock, we can ask parent to see if it contains that property.
    */
	init( selector:String? = nil , parentBlock : Block? = nil ) {
		self.selector = selector
		self.parentBlock = parentBlock
	}

    /**
        Add the declaration.
        Key can either be a property name or variable name.
    */
	func addDeclaration( key : String , value : String ) {
		declarations[key] = value
	}
    
    func addDeclarations( declarations : [String:String] ) {
        for (k,v) in declarations {
            addDeclaration(k,value:v)
        }
    }
	
		
	/** 
		Get the value for the given property or variable.
		If not available, will keep going up to parentBlock recursively and try there.
        If value is a variable, will recurse until it finds non-variable value.
		
		:param:	key	Property or Variable name i.e. "property-name",  "$varName", etc.
	*/
	func getDeclarationValue( key : String ) -> String? {
	
		var ret : String? = nil
		var block : Block? = self
		
		while ret == nil && block != nil {
			ret = block?.declarations[key]
			block = block?.parentBlock
		}
		
        if let ret = ret , retFirstChar = ret.first where retFirstChar == "$" {
            return getDeclarationValue(ret)   // recurse until we have it.
        } else {
            return ret
        }
	}
	
	
	
	
	// MARK: - Protected
	
    /**
        Resolve property values with real values.
        We are going to get rid of all Variables.
    */
    func resolveDeclarations() throws -> [String:String] {
		var ret : [String:String] = Dictionary()
		for (k,v) in declarations {
			if v[0] == "$" {
                guard let valueOfVariable = getDeclarationValue(v) else {
                    throw NXSSError.Require(msg: "Trying to resolve value of variable but cannot find it.", statement: "\(k):\(v)", line:nil)
                }
				ret[k] = valueOfVariable
			} else if k[0] != "$" {
				ret[k] = v
			}
		}
		return ret
	}


	// MARK: - Private
	
	private let parentBlock : Block?
	private var declarations : Declarations = Dictionary()
}
