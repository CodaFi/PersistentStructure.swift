//
//  PersistentHashMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var EMPTY: PersistentHashMap = PersistentHashMap(count: 0, root: nil, hasNull: false, nullValue: nil)
private var _NOT_FOUND: AnyObject = NSNull()

class PersistentHashMap: AbstractPersistentMap, IEditableCollection {
	private var _count: UInt
	private var _root: INode?
	private var _hasNull: Bool
	private var _nullValue: AnyObject?
	private var _meta: IPersistentMap?

	init(count: UInt, root: INode?, hasNull: Bool, nullValue: AnyObject?) {
		_count = count
		_root = root
		_hasNull = hasNull
		_nullValue = nullValue
		_meta = nil
	}

	init(meta: IPersistentMap?, count: UInt, root: INode?, hasNull: Bool, nullValue: AnyObject?) {
		_meta = meta
		_count = count
		_root = root
		_hasNull = hasNull
		_nullValue = nullValue
	}

	func root() -> INode? {
		return _root
	}

	func hasNull() -> Bool {
		return _hasNull
	}

	func nullValue() -> AnyObject {
		return _nullValue!
	}

	func asTransient() -> ITransientCollection {
		return TransientHashMap.create(self)
	}

	class func create(other: IMap?) -> IPersistentMap {
		var ret: ITransientMap? = EMPTY.asTransient() as? ITransientMap
		for o: AnyObject in other!.allEntries()!.generate() {
			let e: IMapEntry = o as! IMapEntry
			ret = ret!.associateKey(e.key()!, value: e.val()!)
		}
		return ret!.persistent()
	}

	/*
	class func createV(init: va_list) -> PersistentHashMap {
		var ret: ITransientMap? = _EmptyPersistentHashMap.asTransient as! ITransientMap?
		for var curVal = va_arg(init, idt); curVal != nil; curVal = va_arg(init, idt) {
		var nxtVal: AnyObject = va_arg(init, idt)
		ret = ret.associateKey(curVal, value: nxtVal)
		}
		return ret.persistent as! PersistentHashMap
	}
*/

	class func createWithSeq(var items: ISeq?) -> PersistentHashMap {
		var ret: ITransientMap? = EMPTY.asTransient() as? ITransientMap
		for ; items != nil; items = items!.next().next() {
			if items!.next().count() == 0 {
				fatalError("No value supplied for key: \(items!.first)")
			}
			ret = ret!.associateKey(items!.first()!, value: Utils.second(items!)!)
		}
		return ret!.persistent() as! PersistentHashMap
	}

	class func createWithCheckSeq(var items: ISeq?) -> PersistentHashMap {
		var ret: ITransientMap? = EMPTY.asTransient() as? ITransientMap
		for var i = 0; items != nil; items = items!.next().next(), i = i.successor() {
			if items!.next().count() == 0 {
				fatalError("No value supplied for key: \(items!.first)")
			}
			ret = ret!.associateKey(items!.first()!, value: Utils.second(items!)!)
			if ret!.count() != UInt(i + 1) {
				fatalError("Duplicate key: \(items!.first)")
			}
		}
		return ret!.persistent() as! PersistentHashMap
	}

	class func createWithMeta(meta: IPersistentMap?, array: Array<AnyObject>) -> PersistentHashMap {
		return PersistentHashMap.createWithSeq(Seq.create(array))
	}

	class func hash(k: AnyObject) -> Int {
		return Utils.hasheq(k)
	}

	override func containsKey(key: AnyObject?) -> Bool {
		if key == nil {
			return _hasNull
		}
		return (_root != nil) ? _root!.findWithShift(0, hash: PersistentHashMap.hash(key!), key: key!, notFound: _NOT_FOUND) !== _NOT_FOUND : false
	}

	override func entryForKey(key: AnyObject?) -> IMapEntry? {
		if key == nil {
			return _hasNull ? MapEntry(key: nil, val: _nullValue) : nil
		}
		return (_root != nil) ? _root!.findWithShift(0, hash: PersistentHashMap.hash(key!), key: key!) : nil
	}

	func associateKey(key: AnyObject?, value val: AnyObject) -> IPersistentMap {
		if key == nil {
			if _hasNull && val === _nullValue {
				return self
			}
			return PersistentHashMap(meta: self.meta(), count: _hasNull ? _count : _count + 1, root: _root, hasNull: true, nullValue: val)
		}
		let addedLeaf: Box = Box(withVal: nil)
		let newroot: INode? = (_root == nil ? BitmapIndexedNode.empty() : _root)!.assocWithShift(0, hash: Int(Utils.hash(key)), key: key!, value: val, addedLeaf: addedLeaf)
		if newroot === _root {
			return self
		}
		return PersistentHashMap(meta: self.meta(), count: addedLeaf.val == nil ? _count : _count + 1, root: newroot, hasNull: _hasNull, nullValue: _nullValue!)
	}

	override func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		if let r = _root {
			if let res = r.findWithShift(0, hash: PersistentHashMap.hash(key), key: key, notFound: notFound) {
				return res
			}
		}
		return notFound
	}

	override func objectForKey(key: AnyObject) -> AnyObject? {
		return self.objectForKey(key, def: NSNull())
	}

	func assocEx(key: AnyObject, value val: AnyObject) -> IPersistentMap {
		if self.containsKey(key) {
			fatalError("Key \(key) already present in hash map \(self)")
		}
		return self.associateKey(key, value: val)
	}

	override func without(key: AnyObject?) -> IPersistentMap {
		if key == nil {
			return _hasNull ? PersistentHashMap(meta: self.meta(), count: _count - 1, root: _root, hasNull: false, nullValue: nil) : self
		}
		if _root == nil {
			return self
		}
		let newroot: INode? = _root!.withoutWithShift(0, hash: PersistentHashMap.hash(key!), key: key!)
		if newroot === _root {
			return self
		}
		return PersistentHashMap(meta: self.meta(), count: _count - 1, root: newroot, hasNull: _hasNull, nullValue: _nullValue)
	}

	func objectEnumerator() -> NSEnumerator {
		return SeqIterator(seq: self.seq())
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, var initial: AnyObject) -> AnyObject {
		initial = _hasNull ? f(initial, nil, _nullValue) : initial
		if Utils.isReduced(initial) {
			return (initial as? IDeref)!.deref()
		}
		if _root != nil {
			return _root!.kvreduce(f, initial: initial)
		}
		return initial
	}

	override func count() -> UInt {
		return _count
	}

	override func seq() -> ISeq {
		if let r = _root {
			if _hasNull {
				return AbstractCons(first: MapEntry(key: nil, val: _nullValue), rest: r.nodeSeq())
			}
		}
		return EmptySeq()
	}

	class func empty() -> IPersistentCollection {
		return EMPTY
	}

	func withMeta(meta: IPersistentMap?) -> PersistentHashMap {
		return PersistentHashMap(meta: _meta, count: _count, root: _root, hasNull: _hasNull, nullValue: _nullValue)
	}

	func meta() -> IPersistentMap? {
		return _meta
	}
}

