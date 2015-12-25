//
//  AbstractSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractSeq : ISeq, ISequential, IList, IHashEq {
	private let _hash : Int
	private let _hasheq : Int
	private let _it : SeqIterator = SeqIterator(seq: nil)
	internal let _meta : IPersistentMap?

	init() {
		_hash = -1
		_hasheq = -1
		_meta = nil
	}

	init(meta : IPersistentMap?) {
		_hash = -1
		_hasheq = -1
		_meta = meta
	}
	
	func equiv(obj: AnyObject) -> Bool {
		if !(obj is ISequential || obj is IList) {
			return false
		}
		var ms : ISeq? = Utils.seq(obj)
		for var s : ISeq? = self.seq(); s != nil; s = s!.next(), ms = ms!.next() {
			if ms == nil || !Utils.equiv(s!.first(), other: ms!.first()) {
				return false
			}
		}
		return ms == nil
	}

	func isEqual(obj: AnyObject) -> Bool {
		if self === obj {
			return true
		}
		if !(obj is ISequential || obj is IList) {
			return false
		}
		var ms: ISeq? = Utils.seq(obj)
		for var s : ISeq? = self.seq(); s != nil; s = s!.next(), ms = ms!.next() {
			if ms == nil || !Utils.isEqual(s!.first(), other: ms!.first()) {
				return false
			}
		}
		return ms == nil
	}

	func count() -> UInt {
		var i : UInt = 1;
		for var s : ISeq? = self.next(); s != nil; s = s!.next(), i = i.successor() {
			if let ss = s as? ICounted {
				return i + ss.count();
			}
		}
		return i;
	}

	func hasheq() -> Int {
		return 0
	}

	func lastIndexOf(other : AnyObject) -> Int {
		return -1
	}

	func subListFromIndex(fromIndex : Int, toIndex: Int) -> IList? {
		return nil
	}

	func containsObject(object: AnyObject) -> Bool {
		return false
	}

	func toArray() -> Array<AnyObject> {
		return []
	}

	func isEmpty() -> Bool {
		return true
	}

	func objectEnumerator() -> NSEnumerator {
		return NSEnumerator()
	}

	func seq() -> ISeq {
		return self
	}

	func first() -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func next() -> ISeq {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func empty() -> IPersistentCollection? {
		return PersistentList.empty()
	}

	func more() -> ISeq {
		if let s : ISeq = self.next() {
			return s
		}
		return PersistentList.empty()
	}

	func cons(other: AnyObject) -> IPersistentCollection? {
		return AbstractCons(first: other, rest: self)
	}

	func cons(other: AnyObject) -> ISeq {
		return AbstractCons(first: other, rest: self)
	}
}
