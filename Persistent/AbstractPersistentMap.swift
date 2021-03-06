//
//  AbstractPersistentMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractPersistentMap : IPersistentMap, IMap, IMapEquivalence, IHashEq {
	var _hash : Int
	var _hasheq : Int

	init() {
		_hash = -1
		_hasheq = -1
	}

	public func cons(o : AnyObject) -> IPersistentCollection {
		if let e = o as? IMapEntry {
			return self.associateKey(e.key, withValue: e.val)
		} else if let v = o as? IPersistentVector {
			guard let k1 = v.objectAtIndex(0), v1 = v.objectAtIndex(1) else {
				fatalError("Vector arg to map conj must be a pair")
			}
			return self.associateKey(k1, withValue: v1)
		} else {
			var ret : IPersistentMap = self
			for var es : ISeq = Utils.seq(o); es.count != 0; es = es.next {
				let e : IMapEntry = es.first as! IMapEntry
				ret = ret.associateKey(e.key, withValue: e.val) as! IPersistentMap
			}
			return ret
		}
	}

	func isEqual(obj : AnyObject) -> Bool {
		return AbstractPersistentMap.mapisEqual(self, other: obj)
	}

	class func mapisEqual(m1: IPersistentMap, other obj: AnyObject) -> Bool {
		if m1 === obj {
			return true
		}
		if !(obj is IMap) {
			return false
		}
		guard let m : IMap = obj as? IMap else {
			return false
		}

		if m.count != m1.count {
			return false
		}
		for var s = m1.seq; s.count != 0; s = s.next {
			if let e = s.first as? IMapEntry {
				let found: Bool = m.containsKey(e.key)
				if !found || !Utils.isEqual(e.val, other: m.objectForKey(e.key)) {
					return false
				}
			}
		}
		return true
	}

	public func equiv(obj: AnyObject) -> Bool {
		if !(obj is IMap) {
			return false
		}
		if !(obj is IPersistentMap) && !(obj is IMapEquivalence) {
			return false
		}

		guard let m = obj as? IMap else {
			return false
		}

		if m.count != self.count {
			return false
		}

		for entry in self.seq.generate() {
			if let e = entry as? IMapEntry {
				let found = m.containsKey(e.key)
				if !found || Utils.equiv(e.val, other: m.objectForKey(e.key)) {
					return false
				}
			}
		}
		return true
	}

	var hash : UInt {
		if _hash == -1 {
			_hash = Int(AbstractPersistentMap.mapHash(self))
		}
		return UInt(_hash)
	}


	static func mapHash(m : IPersistentMap) -> UInt {
		var hash : UInt = 0
		for entry in m.seq.generate() {
			let e : IMapEntry = entry as! IMapEntry
			hash += UInt(e.key.hash ^ e.val.hash)
		}
		return hash
	}

	public var hasheq : Int {
		if _hasheq == -1 {
			_hasheq = AbstractPersistentMap.mapHasheq(self)
		}
		return _hasheq
	}

	static func mapHasheq(m : IPersistentMap) -> Int {
		var hash : Int = 0
		for entry in m.seq.generate() {
			let e : IMapEntry = entry as! IMapEntry
			hash += Int(Utils.hasheq(e.key) ^ Utils.hasheq(e.val))
		}
		return hash
	}

	public var empty : IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var seq : ISeq {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func associateKey(key : AnyObject, withValue value : AnyObject) -> IAssociative {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func entryForKey(key : AnyObject) -> IMapEntry? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func associateEx(key : AnyObject, value : AnyObject) -> IPersistentMap {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func without(key : AnyObject) -> IPersistentMap {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var count : Int {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func objectForKey(key: AnyObject) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func objectForKey(key : AnyObject, def : AnyObject) -> AnyObject {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func setObject(val: AnyObject, forKey key: AnyObject) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func containsKey(key: AnyObject) -> Bool {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func containsValue(value: AnyObject) -> Bool {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var allEntries : ISet {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var isEmpty : Bool {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var allKeys : ISet {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var values : ICollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
