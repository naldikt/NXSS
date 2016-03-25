//
//  Scope.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/26/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

/**
    Scope is used during parsing.
    The main scope (root, top-most) does not have any selector.


    i.e. Say a file consists of:
    """
    // current scope is nil (main)

    foo {
        // current scope is ClassScope foo
        // its parent is Main
    }


    @mixin bar ($a) {
        // current scope is MixinScope bar
        // its parent is Main
    }

    """
*/
class Scope {

	let selector : String?
    let parentScope : Scope?
    
    /** Key-Value pairs */
    private(set) var compiledRuleSets : [String:CompiledRuleSet] = Dictionary()
    private(set) var compiledMixins : [String:CompiledMixin] = Dictionary()

    /**
        - parameters:
            - selector          The selector/name of the scope. nil means it's a root scope.
            - parentScope       It is used for lookup. Say you're in some ClassScope which refers to a property not in that scope. With parentScope, we can ask parent to see if it contains that property.
    */
	init( selector:String? = nil , parentScope : Scope? = nil ) {
		self.selector = selector
		self.parentScope = parentScope
	}
    
    func addCompiledRuleSet(ruleSet:CompiledRuleSet, key:String) {
        self.compiledRuleSets[key] = ruleSet
    }
    
    func addCompiledMixin(mixin:CompiledMixin, key:String) {
        self.compiledMixins[key] = mixin
    }
    
    /**
        Add the declaration.
        Key can either be a property name or variable name (with $ prefix).
    */
	func addDeclaration( key : String , value : String ) {
		declarations[key] = value
	}
    
    func addDeclarations( declarations : [String:String] ) {
        for (key,val) in declarations {
            addDeclaration(key,value:val)
        }
    }
	
		
	/** 
		Get the value for the given property or variable.
		If not available, will keep going up to parentScope recursively and try there.
        If value is a variable, will recurse until it finds non-variable value.
		
		:param:	key	Property or Variable name i.e. "property-name",  "$varName", etc.
	*/
	func getDeclarationValue( key : String ) -> String? {
	
		var ret : String? = nil
		var scope : Scope? = self
		
		while ret == nil && scope != nil {
			ret = scope?.declarations[key]
			scope = scope?.parentScope
		}
		
        if let ret = ret where isVariable(ret) {
            return getDeclarationValue(ret)   // if doesn't exist maybe because it's declared on parent's. Recurse until we have it.
        } else {
            return ret
        }
	}
	
    /** Return all the variables declared within this AND parent's scope */
    func getAllVariables() -> Declarations {
        var ret : Declarations = Dictionary()
        if let parentScope = parentScope {
            ret = parentScope.getAllVariables()
        }
        
        // as this writing there's no ordering. Just happens that self overrides parent's.
        for (key,value) in declarations {
            if isVariable(key) {
                ret[key] = value
            }
        }
        
        return ret
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
	
	private var declarations : Declarations = Dictionary()
    
    
    private func isVariable(key:String) -> Bool {
        if let first = key.first where first == "$" {
            return true
        } else {
            return false
        }
    }
}
