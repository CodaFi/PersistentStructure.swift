//
//  PersistentArrayMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private let HASHTABLE_THRESHOLD: Int = 16
private var EMPTY: PersistentArrayMap = PersistentArrayMap()

class PersistentArrayMap: AbstractPersistentMap, IObj, IEditableCollection {
	private var _array: Array<AnyObject>
	private var _meta: IPersistentMap?

	init(initial: Array<AnyObject>) {
		_array = initial
		_meta = nil
	}

	override init() {
		_array = []
		_meta = nil
		super.init()
	}

//	init(other: IMap?) {
//		var ret: ITransientMap? = EMPTY.asTransient as? ITransientMap
//		for o: AnyObject in other!.allEntries()!.generate() {
//			var e: MapEntry = o as! MapEntry
//			ret = ret!.associateKey(e.key()!, value: e.val()!)
//		}
//		self = (ret!.persistent() as! PersistentArrayMap)
//	}

	func withMeta(meta: IPersistentMap?) -> IObj? {
		return PersistentArrayMap(meta: meta, array: _array)
	}

	init(meta: IPersistentMap?, array initial: Array<AnyObject>) {
		_meta = meta
		_array = initial
		super.init()
	}

	func createHT(initial: Array<AnyObject>) -> IPersistentMap? {
		return PersistentHashMap.createWithMeta(self.meta(), array: initial)
	}

	class func createWithCheck(initial: Array<AnyObject>) -> PersistentArrayMap {
		for var i = 0; i < initial.count; i += 2 {
			for var j = i + 2; j < initial.count; j += 2 {
				if PersistentArrayMap.equalKey(initial[i], other: initial[j]) {
					fatalError("Duplicate key found at index \(i)")
				}
			}
		}
		return PersistentArrayMap(initial: initial)
	}

	override func count() -> UInt {
		return UInt(_array.count) / 2
	}

	override func containsKey(key: AnyObject) -> Bool {
		return self.indexOf(key) >= 0
	}

	override func entryForKey(key: AnyObject) -> IMapEntry? {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return MapEntry(key: _array[i], val: _array[i + 1])
		}
		return nil
	}

	func assocEx(key: AnyObject, value val: AnyObject) -> IPersistentMap? {
		let i: Int = self.indexOf(key)
		var newArray: Array<AnyObject> = []
 		if i >= 0 {
			fatalError("Key \(key) already present in array map \(self)")
		} else {
			if _array.count > HASHTABLE_THRESHOLD {
				return self.createHT(_array)!.associateEx(key, value: val)
			}
			newArray.reserveCapacity(_array.count + 2)
			if _array.count > 0 {
				ArrayCopy(_array, 0, newArray, 2, UInt(_array.count))
			}
			newArray[0] = key
			newArray[1] = val
		}
		return PersistentArrayMap(initial: newArray)
	}

	override func associateKey(key: AnyObject, withValue val: AnyObject) -> IAssociative? {
		let i: Int = self.indexOf(key)
		var newArray: Array<AnyObject>
		if i >= 0 {
			if _array[i + 1] === val {
				return self
			}
			newArray = _array
			newArray[i + 1] = val
		} else {
			if _array.count > HASHTABLE_THRESHOLD {
				return self.createHT(_array)!.associateKey(key, withValue: val)
			}
			newArray = []
			newArray.reserveCapacity(_array.count + 2)
			if _array.count > 0 {
				ArrayCopy(_array, 0, newArray, 2, UInt(_array.count))
			}
			newArray[0] = key
			newArray[1] = val
		}
		return PersistentArrayMap(initial: newArray)
	}

	override func without(key: AnyObject) -> IPersistentMap? {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			let newlen: Int = _array.count - 2
			if newlen == 0 {
				return self.empty() as? IPersistentMap
			}
			var newArray: Array<AnyObject> = []
			newArray.reserveCapacity(newlen)
			for var s = 0, d = 0; s < _array.count; s += 2 {
				if !PersistentArrayMap.equalKey(_array[s], other: key) {
					newArray[d] = _array[s]
					newArray[d + 1] = _array[s + 1]
					d += 2
				}
			}
			return PersistentArrayMap(initial: newArray)
		}
		return self
	}

	override func empty() -> IPersistentCollection? {
		return EMPTY.withMeta(self.meta()) as! IPersistentMap?
	}

	override func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return _array[i + 1]
		}
		return notFound
	}

	override func objectForKey(key: AnyObject) -> AnyObject? {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return _array[i + 1]
		}
		return nil
	}

	func capacity() -> UInt {
		return self.count()
	}

	func indexOfObject(key: AnyObject) -> Int {
		for var i = 0; i < _array.count; i += 2 {
			if _array[i].isEqual(key) {
				return i
			}
		}
		return NSNotFound
	}

	func indexOf(key: AnyObject) -> Int {
		return self.indexOfObject(key)
	}

	class func equalKey(k1: AnyObject, other k2: AnyObject) -> Bool {
		return Utils.equiv(k1, other: k2)
	}

	func objectEnumerator() -> NSEnumerator? {
		return nil
	}

	override func seq() -> ISeq {
		if _array.count > 0 {
			return Seq.create(_array)!
		}
		return EmptySeq()
	}

	func meta() -> IPersistentMap? {
		return _meta
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, var initial: AnyObject) -> AnyObject {
		for var i = 0; i < _array.count; i += 2 {
			initial = f(initial, _array[i], _array[i + 1])
			if Utils.isReduced(initial) {
				return (initial as? IDeref)!.deref()
			}
		}
		return initial
	}

	func asTransient() -> ITransientCollection? {
		return TransientArrayMap(array: _array)
	}
}

