//
//  VectorListIterator.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class VectorListIterator: NSEnumerator {
	private var _vec: IPersistentVector?
	private var _index: UInt

	init(vec: IPersistentVector?, index: UInt) {
		_vec = vec
		_index = index
	}

	override func nextObject() -> AnyObject? {
		_index++
		return _vec!.objectAtIndex(Int(_index))
	}
}
