//
//  AbstractPersistentVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractPersistentVector : IPersistentVector, IList, IRandom, IHashEq /*, Comparable */ {
	private var _hash: Int
	private var _hasheq: Int

	init() {
		_hash = -1
		_hasheq = -1
	}

	func seq() -> ISeq {
		if self.count() > 0 {
			return VecSeq(vector: self, index: 0)
		}
		return EmptySeq()
	}

	func reversedSeq() -> ISeq {
		if self.count() > 0 {
			return RVecSeq(vector: self, index: Int(self.count()) - 1)
		}
		return EmptySeq()
	}

	class func doisEqual(v: IPersistentVector?, object obj: AnyObject) -> Bool {
		if v === obj {
			return true
		}
		if obj is (IList) || obj is (IPersistentVector) {
			let ma: ICollection? = obj as? ICollection
			if ma!.count() != v?.count() /*|| ma!.hash() != v!.hash()*/ {
				return false
			}
			var objec: AnyObject?
			let i1 = (v as? IList)!.objectEnumerator()
			let i2 = ma!.objectEnumerator()
			while objec != nil  {
				objec = i1.nextObject()
				if !Utils.isEqual(objec, other: i2.nextObject()) {
					return false
				}
			}
			return true
		} else {
			if !(obj is ISequential) {
				return false
			}
			var ms: ISeq? = Utils.seq(obj)
			for var i = 0; i < Int(v!.count()); i = i.successor(), ms = ms!.next() {
				if ms == nil || !Utils.isEqual(v!.objectAtIndex(i), other: ms!.first()) {
					return false
				}
			}
			if ms != nil {
				return false
			}
		}
		return true
	}

	class func doEquiv(v: IPersistentVector?, object obj: AnyObject) -> Bool {
		if obj is IList || obj is IPersistentVector {
			let ma: ICollection? = obj as? ICollection
			if ma!.count() != v!.count() {
				return false
			}
			var objec: AnyObject?
			for var i1 = (v as? IList)!.objectEnumerator(), i2 = ma!.objectEnumerator(); objec != nil; {
				objec = i1.nextObject()
				if !Utils.equiv(objec, other: i2.nextObject()) {
					return false
				}
			}
			return true
		} else {
			if !(obj is ISequential) {
				return false
			}
			var ms: ISeq? = Utils.seq(obj)
			for var i = 0; i < Int(v!.count()); i = i.successor(), ms = ms!.next() {
				if ms == nil || !Utils.equiv((v!.objectAtIndex(i)), other: ms!.first()) {
					return false
				}
			}
			if ms != nil {
				return false
			}
		}
		return true
	}

	func isEqual(object: AnyObject) -> Bool {
		return AbstractPersistentVector.doisEqual(self, object: object)
	}

	func equiv(o: AnyObject) -> Bool {
		return AbstractPersistentVector.doEquiv(self, object: o)
	}

	var hash : Int {
		if _hash == -1 {
			var hsh: UInt = 1
			let i: NSEnumerator = self.objectEnumerator()
			var obj: AnyObject? = i.nextObject()
			while obj != nil {
				hsh = 31 * hsh + UInt(obj == nil ? 0 : obj!.hash!)
				obj = i.nextObject()
			}
			_hash = Int(hsh)
		}
		return _hash
	}

	func hasheq() -> Int {
		if _hasheq == -1 {
			var hash: Int = 1
			let i: NSEnumerator = self.objectEnumerator()
			var obj: AnyObject? = i.nextObject()
			while obj != nil {
				hash = 31 * hash + Utils.hasheq(obj)
				obj = i.nextObject()
			}
			_hasheq = hash
		}
		return _hasheq
	}

	func get(index: Int) -> AnyObject? {
		return self.objectAtIndex(index)
	}

	func objectAtIndex(i: Int, def notFound: AnyObject) -> AnyObject {
		if i >= 0 && i < Int(self.count()) {
			return self.objectAtIndex(i)!
		}
		return notFound
	}

	func indexOf(o: AnyObject) -> Int {
		for var i = 0; i < Int(self.count()); i = i.successor() {
			if Utils.equiv((self.objectAtIndex(i))!, other: (o)) {
				return i
			}
		}
		return NSNotFound
	}

	func lastIndexOf(o: AnyObject) -> Int {
		for var i = Int(self.count()) - 1; i >= 0; i-- {
			if Utils.equiv(self.objectAtIndex(i)!, other: (o)) {
				return i
			}
		}
		return NSNotFound
	}

	func subListFromIndex(fromIndex: Int, toIndex: Int) -> IList? {
		return Utils.subvecOf(self, start: fromIndex, end: toIndex) as? IList
	}

	func set(index: Int, element: AnyObject) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func peek() -> AnyObject? {
		if self.count() > 0 {
			return self.objectAtIndex(Int(self.count()) - 1)
		}
		return nil
	}

	func containsKey(key: AnyObject) -> Bool {
		if !Utils.isInteger(key) {
			return false
		}
		let i: Int = (key as! NSNumber).integerValue
		return i >= 0 && i < Int(self.count())
	}

	func entryForKey(key: AnyObject) -> IMapEntry? {
		if !Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < Int(self.count()) {
				return MapEntry(key: key, val: self.objectAtIndex(i)!)
			}
		}
		return nil
	}

	func associateKey(key : AnyObject, withValue value : AnyObject) -> IAssociative? {
		if !Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			return self.assocN(i, value: value)
		}
		fatalError("Key must be integer")
	}

	func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < Int(self.count()) {
				return self.objectAtIndex(i)!
			}
		}
		return notFound
	}

	func objectForKey(key: AnyObject) -> AnyObject? {
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < Int(self.count()) {
				return self.objectAtIndex(i)!
			}
		}
		return nil
	}

	func toArray() -> Array<AnyObject> {
		return Utils.seqToArray(self.seq())
	}

	func isEmpty() -> Bool {
		return self.count() == 0
	}

	func count() -> UInt {
		return 0
	}

	func containsObject(o: AnyObject) -> Bool {
		for var s = self.seq(); s.count() != 0; s = s.next() {
			if Utils.equiv(s.first(), other: o) {
				return true
			}
		}
		return false
	}

	func length() -> Int {
		return Int(self.count())
	}

	func compareTo(o: AnyObject) -> NSComparisonResult {
		let v: IPersistentVector? = o as? IPersistentVector
		if self.count() < v!.count() {
			return .OrderedAscending
		} else if self.count() > v!.count() {
			return .OrderedDescending
		}
		for var i = 0; i < Int(self.count()); i = i.successor() {
			let c: NSComparisonResult = Utils.compare(self.objectAtIndex(i), to: v!.objectAtIndex(i))
			if c != .OrderedSame {
				return c
			}
		}
		return .OrderedSame
	}

	func assocN(i: Int, value val: AnyObject) -> IPersistentVector? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func cons(other: AnyObject) -> IPersistentCollection? {
		fatalError("\(__FUNCTION__) unimplemented")
	}
	
	func cons(o: AnyObject) -> IPersistentVector? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func empty() -> IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func pop() -> IPersistentStack? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func objectAtIndex(i: Int) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func objectEnumerator() -> NSEnumerator {
		return VectorListIterator(vec: self, index: 0)
	}
}
