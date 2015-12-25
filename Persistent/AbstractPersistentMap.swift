//
//  AbstractPersistentMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractPersistentMap : IPersistentMap, IMap, IMapEquivalence, IHashEq {
	var _hash : Int
	var _hasheq : Int

	init() {
		_hash = -1
		_hasheq = -1
	}

	func cons(o : AnyObject) -> IPersistentCollection? {
		if let e = o as? IMapEntry {
			return self.associateKey(e.key()!, withValue: e.val()!)
		} else if let v = o as? IPersistentVector {
			if v.count() != 2 {
				fatalError("Vector arg to map conj must be a pair")
			}
			return self.associateKey(v.objectAtIndex(0)!, withValue: v.objectAtIndex(1)!)
		} else {
			var ret : IPersistentMap = self
			for var es : ISeq? = Utils.seq(o); es != nil; es = es!.next() {
				let e : IMapEntry = es?.first as! IMapEntry
				ret = ret.associateKey(e.key()!, withValue: e.val()!)! as! IPersistentMap
			}
			return ret
		}
	}

	func isEqual(obj : AnyObject) -> Bool {
		return AbstractPersistentMap.mapisEqual(self, other: obj)
	}

	class func mapisEqual(m1: IPersistentMap?, other obj: AnyObject) -> Bool {
		if m1 === obj {
			return true
		}
		if !(obj is IMap) {
			return false
		}
		let m: IMap? = obj as? IMap
		if m!.count() != m1!.count() {
			return false
		}
		for var s = m1!.seq(); s != nil; s = s!.next() {
			let e: IMapEntry? = s!.first() as? IMapEntry
			let found: Bool = m!.containsKey(e!.key()!)
			if !found || !Utils.isEqual(e!.val(), other: m!.objectForKey(e!.key()!)) {
				return false
			}
		}
		return true
	}

	func equiv(obj: AnyObject) -> Bool {
		if !(obj is IMap) {
			return false
		}
		if !(obj is IPersistentMap) && !(obj is IMapEquivalence) {
			return false
		}

		let m : IMap? = obj as? IMap
		if m!.count() != self.count() {
			return false
		}

		for var s : ISeq? = self.seq(); s != nil; s = s!.next() {
			let e : IMapEntry? = s!.first() as? IMapEntry
			let found = m!.containsKey(e!.key()!)
			if !found || Utils.equiv(e!.val(), other: m!.objectForKey(e!.key()!)) {
				return false
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
		for var s : ISeq? = m.seq(); s != nil; s = s!.next() {
			let e : IMapEntry = s!.first as! IMapEntry
			hash += UInt(e.key()!.hash ^ e.val()!.hash)
		}
		return hash
	}

	func hasheq() -> Int {
		if _hasheq == -1 {
			_hasheq = AbstractPersistentMap.mapHasheq(self)
		}
		return _hasheq
	}

	static func mapHasheq(m : IPersistentMap) -> Int {
		var hash : Int = 0
		for var s : ISeq? = m.seq(); s != nil; s = s!.next() {
			let e : IMapEntry = s!.first as! IMapEntry
			hash += Int(Utils.hasheq(e.key()) ^ Utils.hasheq(e.val()))
		}
		return hash
	}

	func empty() -> IPersistentCollection? {
		return nil
	}

	func seq() -> ISeq? {
		return nil
	}

	func associateKey(key : AnyObject, withValue value : AnyObject) -> IAssociative? {
		return nil
	}

	func entryForKey(key : AnyObject) -> IMapEntry? {
		return nil
	}

	func associateEx(key : AnyObject, value : AnyObject) -> IPersistentMap? {
		return nil
	}

	func without(key : AnyObject) -> IPersistentMap? {
		return nil
	}

	func count() -> UInt {
		return 0
	}

	func objectForKey(key: AnyObject) -> AnyObject? {
		return nil
	}

	func objectForKey(key : AnyObject, def : AnyObject?) -> AnyObject? {
		return nil
	}

	func setObject(val: AnyObject, forKey key: AnyObject) -> AnyObject? {
		return nil
	}

	func containsKey(key: AnyObject) -> Bool {
		return false
	}

	func containsValue(value: AnyObject) -> Bool {
		return false
	}

	func allEntries() -> ISet? {
		return nil
	}

	func isEmpty() -> Bool {
		return true
	}

	func allKeys() -> ISet? {
		return nil
	}

	func values() -> ICollection? {
		return nil
	}
}