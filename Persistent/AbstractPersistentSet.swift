//
//  AbstractPersistentSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractPersistentSet : IPersistentSet, ICollection, ISet, IHashEq {
	let _impl: IPersistentMap

	private var _hash: Int32 = 0
	private var _hasheq: Int32 = 0

	init(impl: IPersistentMap) {
		_impl = impl
	}

	public func containsObject(o: AnyObject) -> Bool {
		return _impl.containsKey(o)
	}

	public func objectForKey(key: AnyObject) -> AnyObject {
		return _impl.objectForKey(key)!
	}

	public var count : Int {
		return _impl.count
	}

	public var seq : ISeq {
		return KeySeq(seq: self.seq)
	}

	public func isEqual(o: AnyObject) -> Bool {
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

	public func equiv(o: AnyObject) -> Bool {
		return AbstractPersistentSet.setisEqual(self, other: o)
	}

	var hash : UInt {
		if _hash == -1 {
			var hash: Int32 = 0
			for e in self.seq.generate() {
				hash += Int32(Utils.hash(e))
			}
			_hash = hash
		}
		return UInt(_hash)
	}

	public var hasheq : Int {
		if _hasheq == -1 {
			var hash: Int32 = 0
			for e in self.seq.generate() {
				hash += Utils.hasheq(e)
			}
			_hasheq = hash
		}
		return Int(_hasheq)
	}

	public var toArray : Array<AnyObject> {
		return Utils.seqToArray(self.seq)
	}

	public var isEmpty : Bool {
		return self.count == 0
	}

	public func disjoin(key: AnyObject) -> IPersistentSet {
		fatalError("\(#function) unimplemented")
	}

	public func cons(other : AnyObject) -> IPersistentCollection {
		fatalError("\(#function) unimplemented")
	}

	public var empty : IPersistentCollection {
		fatalError("\(#function) unimplemented")
	}
}
