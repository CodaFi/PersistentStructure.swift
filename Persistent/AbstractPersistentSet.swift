//
//  AbstractPersistentSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractPersistentSet : IPersistentSet, ICollection, ISet, IHashEq {
	var _impl: IPersistentMap?

	private var _hash: Int32 = 0
	private var _hasheq: Int32 = 0

	init(impl: IPersistentMap?) {
		_impl = impl
	}

	func containsObject(o: AnyObject) -> Bool {
		return _impl!.containsKey(o)
	}

	func objectForKey(key: AnyObject) -> AnyObject {
		return _impl!.objectForKey(key)!
	}

	func count() -> UInt {
		return _impl!.count()
	}

	func seq() -> ISeq {
		return KeySeq.create(self.seq())
	}

	func isEqual(o: AnyObject) -> Bool {
		return AbstractPersistentSet.setisEqual(self, other: o)
	}

	class func setisEqual(s1: IPersistentSet?, other obj: AnyObject) -> Bool {
		if s1 === obj {
			return true
		}
		if !(obj is ISet) {
			return false
		}
		let m: ISet? = obj as? ISet
		if m?.count() != s1?.count() {
			return false
		}
		for aM: AnyObject in m!.generate() {
			if !s1!.containsObject(aM) {
				return false
			}
		}
		return true
	}

	func equiv(o: AnyObject) -> Bool {
		return AbstractPersistentSet.setisEqual(self, other: o)
	}

	func hash() -> UInt {
		if _hash == -1 {
			var hash: Int32 = 0
			for var s = self.seq(); s.count() != 0; s = s.next() {
				let e: AnyObject = s.first()!
				hash += Int32(Utils.hash(e))
			}
			_hash = hash
		}
		return UInt(_hash)
	}

	func hasheq() -> Int {
		if _hasheq == -1 {
			var hash: Int32 = 0
			for var s = self.seq(); s.count() != 0; s = s.next() {
				hash += Utils.hasheq(s.first())
			}
			_hasheq = hash
		}
		return Int(_hasheq)
	}

	func toArray() -> Array<AnyObject> {
		return Utils.seqToArray(self.seq())
	}

	func isEmpty() -> Bool {
		return self.count() == 0
	}

	func objectEnumerator() -> NSEnumerator {
		return SeqIterator(seq: self.seq())
	}

	func disjoin(key: AnyObject) -> IPersistentSet? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func cons(other: AnyObject) -> IPersistentCollection? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func empty() -> IPersistentCollection? {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
