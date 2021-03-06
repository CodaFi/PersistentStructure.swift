//
//  PersistentArrayMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private let HASHTABLE_THRESHOLD: Int = 16
private let EMPTY: PersistentArrayMap = PersistentArrayMap()

public class PersistentArrayMap: AbstractPersistentMap, IObj, IEditableCollection {
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

//	init(other: IMap) {
//		var ret: ITransientMap = EMPTY.asTransient() as! ITransientMap
//		for o: AnyObject in other.allEntries().generate() {
//			var e: MapEntry = o as! MapEntry
//			ret = ret.associateKey(e.key, value: e.val)
//		}
//		self = (ret!.persistent as! PersistentArrayMap)
//	}

	public func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentArrayMap(meta: meta, array: _array)
	}

	init(meta: IPersistentMap?, array initial: Array<AnyObject>) {
		_meta = meta
		_array = initial
		super.init()
	}

	func createHT(initial: Array<AnyObject>) -> IPersistentMap {
		return PersistentHashMap.createWithMeta(self.meta, array: initial)
	}

	class func createWithCheck(initial: Array<AnyObject>) -> PersistentArrayMap {
		for i in 0.stride(to: initial.count, by: 2) {
			for j in (i + 2).stride(to: initial.count, by: 2) {
				if PersistentArrayMap.equalKey(initial[i], other: initial[j]) {
					fatalError("Duplicate key found at index \(i)")
				}
			}
		}
		return PersistentArrayMap(initial: initial)
	}

	public override var count : Int {
		return _array.count / 2
	}

	public override func containsKey(key: AnyObject) -> Bool {
		return self.indexOf(key) >= 0
	}

	public override func entryForKey(key: AnyObject) -> IMapEntry? {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return MapEntry(key: _array[i], val: _array[i + 1])
		}
		return nil
	}

	func assocEx(key: AnyObject, value val: AnyObject) -> IPersistentMap {
		let i: Int = self.indexOf(key)
		var newArray: Array<AnyObject> = []
 		if i >= 0 {
			fatalError("Key \(key) already present in array map \(self)")
		} else {
			if _array.count > HASHTABLE_THRESHOLD {
				return self.createHT(_array).associateEx(key, value: val)
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

	public override func associateKey(key: AnyObject, withValue val: AnyObject) -> IAssociative {
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
				return self.createHT(_array).associateKey(key, withValue: val)
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

	public override func without(key: AnyObject) -> IPersistentMap {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			let newlen: Int = _array.count - 2
			if newlen == 0 {
				return self.empty as! IPersistentMap
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

	public override var empty : IPersistentCollection {
		if let m = self.meta {
			return EMPTY.withMeta(m) as! IPersistentCollection
		}
		return EMPTY
	}

	public override func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return _array[i + 1]
		}
		return notFound
	}

	public override func objectForKey(key: AnyObject) -> AnyObject? {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return _array[i + 1]
		}
		return nil
	}

	var capacity : UInt {
		return UInt(self.count)
	}

	func indexOfObject(key: AnyObject) -> Int {
		for i in 0.stride(to: _array.count, by: 2) {
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

	public override var seq : ISeq {
		if _array.count > 0 {
			return Seq(nodes: _array)
		}
		return EmptySeq()
	}

	var meta : IPersistentMap? {
		return _meta
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial ini: AnyObject) -> AnyObject {
		var initial = ini
		for i in 0.stride(to: _array.count, by: 2) {
			initial = f(initial, _array[i], _array[i + 1])
			if Utils.isReduced(initial) {
				return (initial as! IDeref).deref
			}
		}
		return initial
	}

	public var asTransient : ITransientCollection {
		return TransientArrayMap(array: _array)
	}
}

