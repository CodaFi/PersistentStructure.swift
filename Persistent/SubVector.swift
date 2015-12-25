//
//  SubVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class SubVector: AbstractPersistentVector, IObj {
	private var _v: IPersistentVector?
	private var _start: Int
	private var _end: Int
	private var _meta: IPersistentMap?

	init(meta: IPersistentMap?, var vector v: IPersistentVector?, var start: Int, var end: Int) {
		_meta = meta
		if let sv = v! as? SubVector {
			start += sv._start
			end += sv._start
			v = sv._v
		}
		_v = v
		_start = start
		_end = end
	}

	override func objectEnumerator() -> NSEnumerator {
		return NSEnumerator()
	}

	override func objectAtIndex(i: Int) -> AnyObject? {
		if (_start + i >= _end) || (i < 0) {
			fatalError("Range or index out of bounds")
		}
		return _v!.objectAtIndex(_start + i)
	}

	override func assocN(i: Int, value val: AnyObject) -> IPersistentVector {
		if _start + i > _end {
			fatalError("Range or index out of bounds")
		} else if _start + i == _end {
			return self.cons(val)
		}
		return SubVector(meta: _meta, vector: _v!.assocN(_start + i, value: val), start: _start, end: _end)
	}

	override func count() -> UInt {
		return UInt(_end - _start)
	}

	override func cons(o: AnyObject) -> IPersistentVector {
		return SubVector(meta: _meta, vector: _v!.assocN(_end, value: o), start: _start, end: _end + 1)
	}

	override func empty() -> IPersistentCollection {
		if let m = self.meta() {
			return PersistentVector.empty().withMeta(m) as! IPersistentCollection
		}
		return PersistentVector.empty()
	}

	override func pop() -> IPersistentStack {
		if _end - 1 == _start {
			return PersistentVector.empty()
		}
		return SubVector(meta: _meta, vector: _v, start: _start, end: _end - 1)
	}

	func withMeta(meta: IPersistentMap?) -> IObj {
		if meta === _meta {
			return self
		}
		return SubVector(meta: meta, vector: _v, start: _start, end: _end)
	}

	func meta() -> IPersistentMap? {
		return _meta
	}
}
