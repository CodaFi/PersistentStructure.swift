//
//  SubVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class SubVector: AbstractPersistentVector, IObj {
	private var _v: IPersistentVector
	private var _start: Int
	private var _end: Int
	private var _meta: IPersistentMap?

	init(meta: IPersistentMap?, vector v: IPersistentVector, start: Int, end: Int) {
		_meta = meta
		if let sv = v as? SubVector {
			_start = start + sv._start
			_end = end + sv._start
			_v = sv._v
		} else {
			_v = v
			_start = start
			_end = end
		}
		
	}

	public override func objectAtIndex(i: Int) -> AnyObject? {
		if (_start + i >= _end) || (i < 0) {
			fatalError("Range or index out of bounds")
		}
		return _v.objectAtIndex(_start + i)
	}

	public override func assocN(i: Int, value val: AnyObject) -> IPersistentVector {
		if _start + i > _end {
			fatalError("Range or index out of bounds")
		} else if _start + i == _end {
			return self.cons(val)
		}
		return SubVector(meta: _meta, vector: _v.assocN(_start + i, value: val), start: _start, end: _end)
	}

	public override var count : Int {
		return _end - _start
	}

	public override func cons(o: AnyObject) -> IPersistentVector {
		return SubVector(meta: _meta, vector: _v.assocN(_end, value: o), start: _start, end: _end + 1)
	}

	public override var empty : IPersistentCollection {
		if let m = self.meta {
			return PersistentVector.empty.withMeta(m) as! IPersistentCollection
		}
		return PersistentVector.empty
	}

	public override func pop() -> IPersistentStack {
		if _end - 1 == _start {
			return PersistentVector.empty
		}
		return SubVector(meta: _meta, vector: _v, start: _start, end: _end - 1)
	}

	public func withMeta(meta: IPersistentMap?) -> IObj {
		if meta === _meta {
			return self
		}
		return SubVector(meta: meta, vector: _v, start: _start, end: _end)
	}

	var meta : IPersistentMap? {
		return _meta
	}
}
