//
//  Utils.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

func ArrayCopy(src : Array<AnyObject>, _ srcPos : UInt, var _ dest : Array<AnyObject>, _ destPos : UInt, _ length : UInt) -> Array<AnyObject> {
	var mergeArr : Array<AnyObject> = []
	mergeArr.reserveCapacity(Int(length))
	for var i = Int(srcPos), j = 0; i < Int(srcPos + length); i = i.successor(), j = j.successor() {
		mergeArr[j] = src[i];
	}
	for var i = Int(destPos), j = 0; i < Int(destPos + length); i = i.successor(), j = j.successor() {
		dest[i] = mergeArr[j]
	}
	return dest;
}


class Utils: NSObject {
	class func seq(coll: AnyObject) -> ISeq {
		if let cc = coll as? AbstractSeq {
			return cc
		} else if let cc = coll as? LazySeq {
			return cc.seq()
		} else {
			return Utils.seqFrom(coll)
		}
	}

	class func seqFrom(coll: AnyObject) -> ISeq {
		if let cc = coll as? (ISeqable) {
			return cc.seq()
		} else if let cc = coll as? NSString {
			return StringSeq(s: cc)
		} else {
			fatalError("Dont know how to create an object conforming to ISeq from \(coll.dynamicType)")
		}
	}

	class func isEqual(k1: AnyObject?, other k2: AnyObject?) -> Bool {
		if k1 === k2 {
			return true
		}
		return k1 != nil && k1!.isEqual(k2)
	}

	class func equiv(k1: AnyObject?, other k2: AnyObject?) -> Bool {
		return k1 === k2
	}

	class func dohasheq(o: IHashEq?) -> Int {
		return o!.hasheq()
	}

	class func seqToArray(var seq: ISeq?) -> Array<AnyObject> {
		let len: Int = Utils.length(seq)
		var ret: Array<AnyObject> = []
		ret.reserveCapacity(len)
		for var i = 0; seq != nil; i = i.successor(), seq = seq!.next() {
			ret[i] = seq!.first()!
		}
		return ret
	}

	class func length(list: ISeq?) -> Int {
		var i: Int = 0
		for var c = list; c != nil; c = c!.next() {
			i = i.successor()
		}
		return i
	}

	class func count(o: AnyObject) -> Int {
		if let ic = o as? (ICounted) {
			return Int(ic.count())
		}
		return Utils.countFrom(Utils.ret1o(o, null: nil))
	}

	class func countFrom(var o: AnyObject?) -> Int {
		if o == nil {
			return 0
		} else if let _ = o! as? (IPersistentCollection) {
			var s: ISeq? = Utils.seq(o!)
			o = nil
			var i: Int = 0
			for ; s != nil; s = s!.next() {
				if let cc = s as? (ICounted) {
					return i + Int(cc.count())
				}
				i = i.successor()
			}
			return i
		} else if o!.respondsToSelector("length") {
			return o!.length
		} else if o!.respondsToSelector("count") {
			return o!.count
		}
//		RequestConcreteImplementation(o, "count", o.class())
		return -1
	}

	class func containsObject(coll: AnyObject?, key: AnyObject) -> Bool {
		if coll == nil {
			return false
		} else if let c = coll as? (IAssociative) {
			return c.containsKey(key)
		} else if let c = coll as? (IPersistentSet) {
			return c.containsObject(key)
		} else if let m = coll as? (IMap) {
			return m.containsKey(key)
		} else if let s = coll as? (ISet) {
			return s.containsObject(key)
		} else if let c = coll as? (ITransientSet) {
			return c.containsObject(key)
		}
		fatalError("Contains not supported on collection \(coll.dynamicType)")
	}

	class func nthOf(coll: AnyObject, index n: Int) -> AnyObject? {
		if let c = coll as? (IIndexed) {
			return c.objectAtIndex(n)
		}
		return Utils.nthFrom(Utils.ret1s(coll as? ISeq, null: nil), index: n)
	}

	class func nthOf(coll: AnyObject, index n: Int, notFound: AnyObject) -> AnyObject? {
		if let v = coll as? (IIndexed) {
			return v.objectAtIndex(n, def: notFound)
		}
		return Utils.nthFrom(coll, index: n, notFound: notFound)
	}

	class func nthFrom(coll: AnyObject?, index n: Int) -> AnyObject? {
		if coll == nil {
			return nil
		} else if let c = coll as? (NSString) {
			return NSNumber(unsignedShort: c.characterAtIndex(n))
		} else if coll!.respondsToSelector("objectAtIndexedSubscript:") {
			return coll!.performSelector("objectAtIndexedSubscript:", withObject: n).takeRetainedValue()
		} else if let e = coll as? (MapEntry) {
			if n == 0 {
				return e.key()
			} else if n == 1 {
				return e.val()
			}
			fatalError("Range or index out of bounds")
		} else if let _ = coll as? (ISequential) {
			var seq: ISeq? = Utils.seq(coll!)
			for var i = 0; i <= n && seq != nil; i = i.successor(), seq = seq!.next() {
				if i == n {
					return seq!.first()
				}
			}
			fatalError("Range or index out of bounds")
		} else {
//			RequestConcreteImplementation(coll, "nthFrom:index:", coll.dynamicType)
		}
		return nil
	}

	class func nthFrom(coll: AnyObject?, index n: Int, notFound: AnyObject) -> AnyObject? {
		if coll == nil {
			return notFound
		} else if n < 0 {
			return notFound
		} else if let e = coll as? (IMapEntry) {
			if n == 0 {
				return e.key()
			} else if n == 1 {
				return e.val()
			}
			return notFound
		} else if let _ = coll as? (ISequential) {
			var seq: ISeq? = Utils.seq(coll!)
			for var i = 0; i <= n && seq != nil; i = i.successor(), seq = seq!.next() {
				if i == n {
					return seq!.first()
				}
			}
			return notFound
		} else {
//			RequestConcreteImplementation(coll, "nthFrom:index:", coll.class())
		}
		return nil
	}

	class func cons(x: AnyObject, to coll: AnyObject?) -> ISeq {
		if coll == nil {
			return PersistentList(first: x)
		} else if let cc = coll as? (ISeq) {
			return AbstractCons(first: x, rest: cc)
		} else {
			return AbstractCons(first: x, rest: Utils.seq(coll!))
		}
	}

	class func conj(x: AnyObject, to coll: IPersistentCollection?) -> IPersistentCollection? {
		if coll == nil {
			return PersistentList(first: x)
		}
		return coll!.cons(x)
	}

	class func subvecOf(v: IPersistentVector?, start: Int, end: Int) -> IPersistentVector? {
		if end < start || start < 0 || end > Int(v!.count()) {
			fatalError("Range or index out of bounds")
		}
		if start == end {
			return PersistentVector.empty()
		}
		return SubVector(meta: nil, vector: v, start: start, end: end)
	}

	class func associateKey(key: AnyObject, to val: AnyObject, into coll: AnyObject?) -> IAssociative {
		if coll == nil {
			return PersistentArrayMap(initial: [])
		}
		return (coll as? IAssociative)!.associateKey(key, withValue: val)
	}

	class func first(x: AnyObject) -> AnyObject? {
		if let ss = x as? (ISeq) {
			return ss.first()
		}
		let seq: ISeq? = Utils.seq(x)
		if seq == nil {
			return nil
		}
		return seq!.first()
	}

	class func second(x: AnyObject) -> AnyObject? {
		return Utils.first(Utils.next(x)!)
	}

	class func third(x: AnyObject) -> AnyObject? {
		return Utils.first(Utils.next(Utils.next(x)!)!)
	}

	class func fourth(x: AnyObject) -> AnyObject? {
		return Utils.first(Utils.next(Utils.next(Utils.next(x)!)!)!)
	}

	class func next(x: AnyObject) -> ISeq? {
		if let ss = x as? (ISeq) {
			return ss.next()
		}
		let seq: ISeq? = Utils.seq(x)
		if seq == nil {
			return nil
		}
		return seq!.next()
	}

	class func more(x: AnyObject) -> ISeq? {
		if let ss = x as? (ISeq) {
			return ss.more()
		}
		let seq: ISeq? = Utils.seq(x)
		if seq == nil {
			return nil
		}
		return seq!.more()
	}

	class func ret1o(ret: AnyObject, null: AnyObject?) -> AnyObject {
		return ret
	}

	class func ret1s(ret: ISeq?, null: AnyObject?) -> ISeq? {
		return ret
	}

	class func isReduced(x: AnyObject) -> Bool {
		return (x as? Reduced) != nil
	}

	class func isInteger(obj: AnyObject) -> Bool {
		return obj.isKindOfClass(NSNumber.self)
			|| obj.isKindOfClass(NSString.self)
			|| obj.isKindOfClass(NSValue.self)
	}

	class func hash(obj: AnyObject?) -> UInt {
		return obj != nil ? UInt(obj!.hash!) : 0
	}

	class func hasheq(o: AnyObject?) -> Int {
		if o == nil {
			return 0
		}
		if let ih = o as? (IHashEq) {
			return Utils.dohasheq(ih)
		}
		return o!.hash
	}

	class func _emptyArray() -> Array<AnyObject> {
		return []
	}

	class func bitCount(ix: UInt) -> Int {
		var i : Int = Int(ix)
		i = i - ((i >> 1) & 0x55555555)
		i = (i & 0x33333333) + ((i >> 2) & 0x33333333)
		return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24
	}

	class func bitPos(hash: Int, shift: Int) -> Int {
		return 1 << Utils.mask(hash, shift: shift)
	}

	class func mask(x: Int, shift n: Int) -> Int {
		let mask: Int = ~(-1 << n) << (32 - n)
		return ~mask & ((x >> n) | mask) & 0x01f
	}

	class func cloneAndSetNode(array: Array<AnyObject>, index i: Int, node a: INode?) -> Array<AnyObject> {
		var clone: Array<AnyObject> = array
		clone[i] = a!
		return clone
	}

	class func cloneAndSetObject(array: Array<AnyObject>, index i: Int, node a: AnyObject) -> Array<AnyObject> {
		var clone: Array<AnyObject> = array
		clone[i] = a
		return clone
	}

	class func cloneAndSet(array: Array<AnyObject>, index i: Int, withObject a: AnyObject, index j: Int, withObject b: AnyObject) -> Array<AnyObject> {
		var clone: Array<AnyObject> = array
		clone[i] = a
		clone[j] = b
		return clone
	}

	class func removePair(array: Array<AnyObject>, index i: Int) -> Array<AnyObject> {
		var newArray: Array<AnyObject> = []
		newArray.reserveCapacity(array.count - 2)
		ArrayCopy(array, 0, newArray, 0, UInt(2 * i))
		ArrayCopy(array, UInt(2 * (i + 1)), newArray, UInt(2 * i), UInt(newArray.count - 2 * i))
		return newArray
	}

	class func createNodeWithShift(shift: Int, key key1: AnyObject, value val1: AnyObject, hash key2hash: Int, key key2: AnyObject, value val2: AnyObject) -> INode? {
		let key1hash: Int = Int(Utils.hash(key1))
		if key1hash == key2hash {
			return HashCollisionNode(edit: nil, hash: key1hash, count: 2, array: [ key1, val1, key2, val2 ])
		}
		let addedLeaf: Box = Box(withVal: nil)
		let edit: NSThread = NSThread.currentThread()
		return BitmapIndexedNode
			.empty()
			.assocOnThread(edit, shift: shift, hash: key1hash, key: key1, val: val1, addedLeaf: addedLeaf)!
			.assocOnThread(edit, shift: shift, hash: key2hash, key: key2, val: val2, addedLeaf: addedLeaf)
	}

	class func createNodeOnThread(edit: NSThread, shift: Int, key key1: AnyObject, value val1: AnyObject, hash key2hash: Int, key key2: AnyObject, value val2: AnyObject) -> INode? {
		let key1hash: Int = Int(Utils.hash(key1))
		if key1hash == key2hash {
			return HashCollisionNode(edit: nil, hash: key1hash, count: 2, array: [key1, val1, key2, val2])
		}
		let addedLeaf: Box = Box(withVal: nil)
		return BitmapIndexedNode.empty().assocOnThread(edit, shift: shift, hash: key1hash, key: key1, val: val1, addedLeaf: addedLeaf)!.assocOnThread(edit, shift: shift, hash: key2hash, key: key2, val: val2, addedLeaf: addedLeaf)
	}

	class func compare(k1: AnyObject?, to k2: AnyObject?) -> NSComparisonResult {
		if k1 === k2 {
			return .OrderedSame
		}
		if k1 != nil {
			if k2 == nil {
				return .OrderedAscending
			}
			if k1!.respondsToSelector("compare:") {
				return k1!.compare(k2!)
			}
			return .OrderedSame
//			return (k1 as? Comparable)!.compareTo(k2)
		}
		return .OrderedDescending
	}

	class func keys(coll: AnyObject) -> ISeq {
		return KeySeq.create(Utils.seq(coll))
	}

	class func vals(coll: AnyObject) -> ISeq {
		return ValSeq.create(Utils.seq(coll))
	}

	class func list(arg1: AnyObject) -> ISeq {
		return PersistentList(first: arg1)
	}
}