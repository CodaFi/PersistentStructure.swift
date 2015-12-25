//
//  RVecSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class RVecSeq: AbstractSeq, IIndexedSeq {
	private var _backingVector: IPersistentVector?
	private var _startingIndex: Int

	init(vector: IPersistentVector?, index: Int) {
		_backingVector = vector
		_startingIndex = index
		super.init()
	}

	init(meta: IPersistentMap?, vector: IPersistentVector?, index: Int) {
		_backingVector = vector
		_startingIndex = index
		super.init(meta: meta)
	}

	override func first() -> AnyObject {
		return _backingVector!.objectAtIndex(_startingIndex)!
	}

	override func next() -> ISeq? {
		if _startingIndex > 0 {
			return RVecSeq(vector: _backingVector, index: _startingIndex - 1)
		}
		return nil
	}

	func index() -> Int {
		return _startingIndex
	}

	override func count() -> UInt {
		return UInt(_startingIndex + 1)
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		return RVecSeq(meta: meta, vector: _backingVector, index: _startingIndex)
	}
}
