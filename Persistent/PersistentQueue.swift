//
//  PersistentQueue.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var EMPTY: PersistentQueue = PersistentQueue(meta: nil, count: 0, seq: EmptySeq(), rev: PersistentVector.empty())

class PersistentQueue: Obj, IPersistentList, ICollection, ICounted, IHashEq {
	private var _count: Int
	private var _front: ISeq
	private var _rear: IPersistentVector
	private var _hash: Int
	private var _hasheq: Int

	init(meta: IPersistentMap?, count cnt: Int, seq f: ISeq, rev r: IPersistentVector) {
		_count = cnt
		_front = f
		_rear = r
		_hash = -1
		_hasheq = -1
		super.init(meta: meta)
	}

	func equiv(obj: AnyObject) -> Bool {
		if !(obj is ISequential) {
			return false
		}
		for (e1, e2) in zip(self.seq().generate(), Utils.seq(obj).generate()) {
			if !Utils.equiv(e1, other: e2) {
				return false
			}
		}
		return self.seq().count == Utils.seq(obj).count
	}

	func isEqual(obj: AnyObject) -> Bool {
		if !(obj is ISequential) {
			return false
		}
		for (e1, e2) in zip(self.seq().generate(), Utils.seq(obj).generate()) {
			if !Utils.equiv(e1, other: e2) {
				return false
			}
		}
		return self.seq().count == Utils.seq(obj).count
	}

	func hash() -> UInt {
		if _hash == -1 {
			var hash: UInt = 1
			for var s = self.seq(); s.count != 0; s = s.next() {
				hash = 31 * hash + (s.first() == nil ? 0 : UInt(s.first()!.hash!))
			}
			_hash = Int(hash)
		}
		return UInt(_hash)
	}

	func hasheq() -> Int {
		if _hasheq == -1 {
			_hasheq = Int(Murmur3.hashOrdered(self))
		}
		return _hasheq
	}

	func peek() -> AnyObject? {
		return Utils.first(_front)
	}

	func pop() -> IPersistentStack {
		var f1: ISeq = _front.next()
		var r1: IPersistentVector = _rear
		if f1.count == 0 {
			f1 = Utils.seq(_rear)
			r1 = PersistentVector.empty()
		}
		return PersistentQueue(meta: self.meta(), count: _count - 1, seq: f1, rev: r1)
	}

	var count : Int {
		return _count
	}

	func seq() -> ISeq {
		if _front.count == 0 {
			return EmptySeq()
		}
		return QueueSeq(f: _front, rev: Utils.seq(_rear))
	}

	func cons(other : AnyObject) -> IPersistentCollection {
		if _front.count == 0 {
			return PersistentQueue(meta: self.meta(), count: _count + 1, seq: Utils.list(other), rev: PersistentVector.empty())
		} else {
			return PersistentQueue(meta: self.meta(), count: _count + 1, seq: _front, rev: (_rear.count != 0 ? _rear : PersistentVector.empty().cons(other)))
		}
	}

	func empty() -> IPersistentCollection {
		if let m = self.meta() {
			return EMPTY.withMeta(m) as! IPersistentCollection
		}
		return EMPTY
	}

	override func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentQueue(meta: meta, count: _count, seq: _front, rev: _rear)
	}

	func toArray() -> Array<AnyObject> {
		return Utils.seqToArray(self.seq())
	}

	var isEmpty : Bool {
		return self.count == 0
	}

	func containsObject(anObject: AnyObject) -> Bool {
		for var s = self.seq(); s.count != 0; s = s.next() {
			if Utils.equiv(s.first(), other: anObject) {
				return true
			}
		}
		return false
	}
}
