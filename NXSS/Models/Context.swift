
class Context {

	let name : String?

	init( name:String? = nil , parentContext : Context? = nil ) {
		self.name = name
		self.parentContext = parentContext
	}

	func addVariable( name : String , value : String ) {
		variables[name] = value
	}
	
		
	/** 
		Get the value for the given variable.
		If not available, will keep going up to parentContexts and try there.
		
		:param:	name	Variable name i.e. "$varName"
	*/
	func getVariableValue( name : String ) -> String? {
	
		var ret : String? = nil
		var context : Context? = self
		
		while ret == nil && context != nil {
			ret = context?.variables[name]
			context = context?.parentContext
		}
		
		return ret
	}
	
	
	func addEntry( name : String , value : String ) {
		entries[name] = value
	}
	
	func addEntries( entries : [String:String] ) {
		for (k,v) in entries {
			addEntry(k,value:v)
		}
	}
	
	/**
		Get an entry declared in this context.
	*/
	func getEntry(name : String) -> String? {
		return entries[name]
	}	
	
	
	// MARK: - Protected
	
	func resolveEntries() -> [String:String] {
		var ret : [String:String] = Dictionary()
		for (k,v) in entries {
			if v[0] == "$" {
				let valueOfVariable = getVariableValue(v)
				assert(valueOfVariable != nil , "Value is not found. Maybe not defined?")
				ret[k] = valueOfVariable 
				
			} else {
				ret[k] = v
			}
		}
		return ret
	}


	// MARK: - Private
	
	let parentContext : Context?
    
    // Subclasses shouldn't access this directly.
    // See getVariableValue() and other methods.
	private var variables : [String:String] = Dictionary()
	private var entries : [String:String] = Dictionary()
}



