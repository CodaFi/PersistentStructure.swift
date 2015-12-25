//
//  ArrayChunk.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class ArrayChunk : IChunk {
	private var _array: Array<AnyObject>
	private var _off: Int
	private var _end: Int

	convenience init(array: Array<AnyObject>) {
		self.init(array: array, offset: 0, end: array.count)
	}

	convenience init(array: Array<AnyObject>, offset: Int) {
		self.init(array: array, offset: offset, end: array.count)
	}

	init(array: Array<AnyObject>, offset: Int, end: Int) {
		_array = array
		_off = offset
		_end = end
	}

	func objectAtIndex(i: Int) -> AnyObject? {
		return _array[_off + i]
	}

	func objectAtIndex(i: Int, def notFound: AnyObject) -> AnyObject? {
		if i >= 0 && i < Int(self.count()) {
			return self.objectAtIndex(i)
		}
		return notFound
	}

	func count() -> UInt {
		return UInt(_end - _off)
	}

	func tail() -> IChunk {
		if _off == _end {
			fatalError("Cannot request tail of empty chunk.")
		}
		return ArrayChunk(array: _array, offset: _off + 1, end: _end)
	}

	func reduce(f: (AnyObject, AnyObject) -> AnyObject, start: AnyObject) -> AnyObject {
		var ret: AnyObject = f(start, _array[_off])
		if Utils.isReduced(ret) {
			return ret
		}
		for var x = _off + 1; x < _end; x++ {
			ret = f(ret, _array[x])
			if Utils.isReduced(ret) {
				return ret
			}
		}
		return ret
	}
}
