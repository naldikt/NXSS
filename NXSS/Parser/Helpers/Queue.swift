//
//  Queue.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/26/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

/**
    Generic implementation of Queue.
*/
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