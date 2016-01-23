//
//  PersistentVectorIterator.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class PersistentVectorIterator: NSEnumerator {
	private var _vec: PersistentVector
	private var _start: Int
	private var _base: Int
	private var _window: Array<AnyObject>

	init(vec: PersistentVector, start index: Int) {
		_vec = vec
		_start = index
		_base = _start - (_start % 32)
		_window = (_start < _vec.count) ? _vec.arrayFor(_start) : []
	}

	public override func nextObject() -> AnyObject? {
		if _start - _start == 32 {
			_window = _vec.arrayFor(_start)
			_base += 32
		}
		_start = _start.successor()
		return _window[_start & 0x01f]
	}
}