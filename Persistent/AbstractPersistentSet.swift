//
//  AbstractPersistentSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractPersistentSet : IPersistentSet, ICollection, ISet, IHashEq {
	let _impl: IPersistentMap

	private var _hash: Int32 = 0
	private var _hasheq: Int32 = 0

	init(impl: IPersistentMap) {
		_impl = impl
	}

	func containsObject(o: AnyObject) -> Bool {
		return _impl.containsKey(o)
	}

	func objectForKey(key: AnyObject) -> AnyObject {
		return _impl.objectForKey(key)!
	}

	var count : Int {
		return _impl.count
	}

	var seq : ISeq {
		return KeySeq(seq: self.seq)
	}

	func isEqual(o: AnyObject) -> Bool {
		return AbstractPersistentSet.setisEqual(self, other: o)
	}

	class func setisEqual(seq1: IPersistentSet?, other obj: AnyObject) -> Bool {
		if seq1 === obj {
			return true
		}
		
		guard let m = obj as? ISet, s1 = seq1 else {
			return false
		}
		
		if m.count != s1.count {
			return false
		}
		for aM in m.generate() {
			if !s1.containsObject(aM) {
				return false
			}
		}
		return true
	}

	func equiv(o: AnyObject) -> Bool {
		return AbstractPersistentSet.setisEqual(self, other: o)
	}

	var hash : UInt {
		if _hash == -1 {
			var hash: Int32 = 0
			for var s = self.seq; s.count != 0; s = s.next {
				let e: AnyObject = s.first!
				hash += Int32(Utils.hash(e))
			}
			_hash = hash
		}
		return UInt(_hash)
	}

	var hasheq : Int {
		if _hasheq == -1 {
			var hash: Int32 = 0
			for var s = self.seq; s.count != 0; s = s.next {
				hash += Utils.hasheq(s.first)
			}
			_hasheq = hash
		}
		return Int(_hasheq)
	}

	var toArray : Array<AnyObject> {
		return Utils.seqToArray(self.seq)
	}

	var isEmpty : Bool {
		return self.count == 0
	}

	func disjoin(key: AnyObject) -> IPersistentSet {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func cons(other : AnyObject) -> IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	var empty : IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
