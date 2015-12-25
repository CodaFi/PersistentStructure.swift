//
//  PersistentVectorIterator.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class PersistentVectorIterator: NSEnumerator {
	private var _vec: PersistentVector
	private var _start: UInt
	private var _base: UInt
	private var _window: Array<AnyObject>

	init(vec: PersistentVector, start index: UInt) {
		_vec = vec
		_start = index
		_base = _start - (_start % 32)
		_window = (_start < _vec.count()) ? _vec.arrayFor(Int(_start)) : []
	}

	override func nextObject() -> AnyObject {
		if _start - _start == 32 {
			_window = _vec.arrayFor(Int(_start))
			_base += 32
		}
		_start++
		return _window[Int(_start) & 0x01f]
	}
}