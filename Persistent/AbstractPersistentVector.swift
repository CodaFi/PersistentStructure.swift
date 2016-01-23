//
//  AbstractPersistentVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractPersistentVector : IPersistentVector, IList, IRandom, IHashEq /*, Comparable */ {
	private var _hash: Int
	private var _hasheq: Int

	init() {
		_hash = -1
		_hasheq = -1
	}

	public var seq : ISeq {
		if self.count > 0 {
			return VecSeq(vector: self, index: 0)
		}
		return EmptySeq()
	}

	public var reversedSeq : ISeq {
		if self.count > 0 {
			return RVecSeq(vector: self, index: Int(self.count) - 1)
		}
		return EmptySeq()
	}

	class func doisEqual(vec: IPersistentVector?, object obj: AnyObject) -> Bool {
		if vec === obj {
			return true
		}
		
		guard let v = vec else {
			return false
		}
		
		if obj is IList || obj is IPersistentVector {
			guard let ma = obj as? ICollection, va = v as? IList else {
				return false
			}

			if ma.count != va.count /*|| ma.hash() != v!.hash()*/ {
				return false
			}

			for (l, r) in zip(ma.generate(), va.generate()) {
				if !Utils.isEqual(l, other: r) {
					return false
				}
			}
			return true
		} else {
			if !(obj is ISequential) {
				return false
			}
			let ms: ISeq = Utils.seq(obj)
			for (entry, i) in zip(ms.generate(), (0..<ms.count)) {
				if !Utils.isEqual(v.objectAtIndex(i), other: entry) {
					return false
				}
			}
//			if ms != nil {
//				return false
//			}
		}
		return true
	}

	class func doEquiv(v: IPersistentVector, object obj: AnyObject) -> Bool {
		if obj is IList || obj is IPersistentVector {
			guard let ma = obj as? ICollection, objc = obj as? IList else {
				return false
			}

			if ma.count != v.count {
				return false
			}

			for (l, r) in zip(ma.generate(), objc.generate()) {
				if !Utils.equiv(l, other: r) {
					return false
				}
			}
			return true
		} else {
			if !(obj is ISequential) {
				return false
			}
			let ms: ISeq = Utils.seq(obj)
			for (entry, i) in zip(ms.generate(), (0..<ms.count)) {
				if !Utils.equiv((v.objectAtIndex(i)), other: entry) {
					return false
				}
			}
//			if ms != nil {
//				return false
//			}
		}
		return true
	}

	public func isEqual(object: AnyObject) -> Bool {
		return AbstractPersistentVector.doisEqual(self, object: object)
	}

	public func equiv(o: AnyObject) -> Bool {
		return AbstractPersistentVector.doEquiv(self, object: o)
	}

	var hash : Int {
		if _hash == -1 {
			var hsh: UInt = 1
			for obj in self.generate() {
				hsh = 31 * hsh + UInt(obj.hash!)
			}
			_hash = Int(hsh)
		}
		return _hash
	}

	public var hasheq : Int {
		if _hasheq == -1 {
			var hash: Int = 1
			for obj in self.generate() {
				hash = 31 * hash + Utils.hasheq(obj)
			}
			_hasheq = hash
		}
		return _hasheq
	}

	func get(index: Int) -> AnyObject? {
		return self.objectAtIndex(index)
	}

	public func objectAtIndex(i: Int, def notFound: AnyObject) -> AnyObject {
		if i >= 0 && i < Int(self.count) {
			return self.objectAtIndex(i)!
		}
		return notFound
	}

	func indexOf(o: AnyObject) -> Int {
		for i in (0..<self.count) {
			if Utils.equiv((self.objectAtIndex(i))!, other: (o)) {
				return i
			}
		}
		return NSNotFound
	}

	public func lastIndexOf(o: AnyObject) -> Int {
		for var i = Int(self.count) - 1; i >= 0; i-- {
			if Utils.equiv(self.objectAtIndex(i)!, other: (o)) {
				return i
			}
		}
		return NSNotFound
	}

	public func subListFromIndex(fromIndex: Int, toIndex: Int) -> IList? {
		return Utils.subvecOf(self, start: fromIndex, end: toIndex) as? IList
	}

	func set(index: Int, element: AnyObject) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var peek : AnyObject? {
		if self.count > 0 {
			return self.objectAtIndex(Int(self.count) - 1)
		}
		return nil
	}

	public func containsKey(key: AnyObject) -> Bool {
		if !Utils.isInteger(key) {
			return false
		}
		let i: Int = (key as! NSNumber).integerValue
		return i >= 0 && i < Int(self.count)
	}

	public func entryForKey(key: AnyObject) -> IMapEntry? {
		if !Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < Int(self.count) {
				return MapEntry(key: key, val: self.objectAtIndex(i)!)
			}
		}
		return nil
	}

	public func associateKey(key : AnyObject, withValue value : AnyObject) -> IAssociative {
		if !Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			return self.assocN(i, value: value)
		}
		fatalError("Key must be integer")
	}

	public func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < Int(self.count) {
				return self.objectAtIndex(i)!
			}
		}
		return notFound
	}

	public func objectForKey(key: AnyObject) -> AnyObject? {
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < Int(self.count) {
				return self.objectAtIndex(i)!
			}
		}
		return nil
	}

	public var toArray : Array<AnyObject> {
		return Utils.seqToArray(self.seq)
	}

	public var isEmpty : Bool {
		return self.count == 0
	}

	public var count : Int {
		return 0
	}

	public func containsObject(o: AnyObject) -> Bool {
		for var s = self.seq; s.count != 0; s = s.next {
			if Utils.equiv(s.first, other: o) {
				return true
			}
		}
		return false
	}

	var length : Int {
		return Int(self.count)
	}

	func compareTo(o: AnyObject) -> NSComparisonResult {
		guard let v = o as? IPersistentVector else {
			fatalError("Cannot compare to non-persistent vector type")
		}

		if self.count < v.count {
			return .OrderedAscending
		} else if self.count > v.count {
			return .OrderedDescending
		}
		for i in (0..<self.count) {
			let c: NSComparisonResult = Utils.compare(self.objectAtIndex(i), to: v.objectAtIndex(i))
			if c != .OrderedSame {
				return c
			}
		}
		return .OrderedSame
	}

	public func assocN(i: Int, value val: AnyObject) -> IPersistentVector {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func cons(other : AnyObject) -> IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}
	
	public func cons(o: AnyObject) -> IPersistentVector {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var empty : IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func pop() -> IPersistentStack {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public func objectAtIndex(i: Int) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
