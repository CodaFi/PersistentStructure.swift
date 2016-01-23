//
//  VecSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class VecSeq: AbstractSeq, IIndexedSeq, IReducible {
	private var _vector: IPersistentVector
	private var _index: Int

	init(vector: IPersistentVector, index i: Int) {
		_vector = vector
		_index = i
		super.init()
	}

	init(meta: IPersistentMap?, vector v: IPersistentVector, index i: Int) {
		_vector = v
		_index = i
		super.init(meta: meta)
	}

	override var first : AnyObject {
		return _vector.objectAtIndex(_index)!
	}

	override var next : ISeq {
		if (_index + 1) < _vector.count {
			return VecSeq(vector: _vector, index: _index + 1)
		}
		return EmptySeq()
	}

	var currentIndex : Int {
		return _index
	}

	override var count : Int {
		return _vector.count - _index
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		return VecSeq(meta: meta, vector: _vector, index: _index)
	}

	func reduce(combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
		var ret: AnyObject = _vector.objectAtIndex(_index)!
		for var x = _index + 1; x < _vector.count; x = x.successor() {
			ret = combine(ret, _vector.objectAtIndex(x)!)
		}
		return ret
	}

	func reduce(initial: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
		var ret: AnyObject = combine(initial, _vector.objectAtIndex(_index)!)
		for var x = _index + 1; x < _vector.count; x = x.successor() {
			ret = combine(ret, _vector.objectAtIndex(x)!)
		}
		return ret
	}
}