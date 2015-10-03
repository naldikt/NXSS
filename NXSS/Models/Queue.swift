
class Queue<T> {
	
	/** Push entry. */
	func push( entry : T ) {
		array.append(entry)
	}
	
	/** If there's no entry it'll crash. */
	func peek() -> T {
		return array.last!
	}
		
	/** Pop and return. */
	func pop() -> T {
		return array.removeLast()
	}
	
	/** If there's any entry left. */
	func hasEntry() -> Bool {
        return array.count > 0
	}
	
	// MARK: - Private
	
	var array : [T] = []
}