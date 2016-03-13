//
//  PersistentHashMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private let EMPTY: PersistentHashMap = PersistentHashMap(count: 0, root: nil, hasNull: false, nullValue: nil)
private var _NOT_FOUND: AnyObject = NSNull()

public class PersistentHashMap: AbstractPersistentMap, IEditableCollection {
	private var _count: Int
	private var _root: INode?
	private var _hasNull: Bool
	private var _nullValue: AnyObject?
	private var _meta: IPersistentMap?

	init(count: Int, root: INode?, hasNull: Bool, nullValue: AnyObject?) {
		_count = count
		_root = root
		_hasNull = hasNull
		_nullValue = nullValue
		_meta = nil
	}

	init(meta: IPersistentMap?, count: Int, root: INode?, hasNull: Bool, nullValue: AnyObject?) {
		_meta = meta
		_count = count
		_root = root
		_hasNull = hasNull
		_nullValue = nullValue
	}

	var root : INode? {
		return _root
	}

	var hasNull : Bool {
		return _hasNull
	}

	var nullValue : AnyObject {
		return _nullValue!
	}

	public var asTransient : ITransientCollection {
		return TransientHashMap(withMap: self)
	}

	class func create(othere: IMap?) -> IPersistentMap {
		guard let other = othere else {
			return EMPTY
		}
		
		var ret: ITransientMap = EMPTY.asTransient as! ITransientMap
		for o: AnyObject in other.allEntries.generate() {
			let e: IMapEntry = o as! IMapEntry
			ret = ret.associateKey(e.key, value: e.val)
		}
		return ret.persistent()
	}

	class func createWithSeq(items: ISeq) -> PersistentHashMap {
		var ret: ITransientMap? = EMPTY.asTransient as? ITransientMap
		var sink : (AnyObject?, AnyObject?) = (nil, nil)
		for e in items.generate() {
			if let l = sink.0, r = sink.1 {
				ret = ret!.associateKey(l, value: r)
				sink = (e, nil)
			} else if sink.0 == nil {
				sink = (e, nil)
			} else if let l = sink.0 {
				sink = (l, e)
			} else {
				fatalError("impossible")
			}
		}
		guard sink.1 == nil else {
			fatalError("Unassociated key in hash map")
		}
		
		return ret!.persistent() as! PersistentHashMap
	}

//	class func createWithCheckSeq(items: ISeq?) -> PersistentHashMap {
//		var ret: ITransientMap? = EMPTY.asTransient as? ITransientMap
//		for var i = 0; items != nil; items = items!.next.next, i = i.successor() {
//			if items!.next.count == 0 {
//				fatalError("No value supplied for key: \(items!.first)")
//			}
//			ret = ret!.associateKey(items!.first!, value: Utils.second(items!)!)
//			if ret!.count != (i + 1) {
//				fatalError("Duplicate key: \(items!.first)")
//			}
//		}
//		return ret!.persistent() as! PersistentHashMap
//	}

	class func createWithMeta(meta: IPersistentMap?, array: Array<AnyObject>) -> PersistentHashMap {
		return PersistentHashMap.createWithSeq(Seq(nodes: array))
	}

	class func hash(k: AnyObject) -> Int {
		return Utils.hasheq(k)
	}

	public override func containsKey(key: AnyObject) -> Bool {
		guard let r = _root else {
			return false
		}
		return r.findWithShift(0, hash: PersistentHashMap.hash(key), key: key, notFound: _NOT_FOUND) !== _NOT_FOUND
	}

	public override func entryForKey(key: AnyObject) -> IMapEntry? {
		return _root?.findWithShift(0, hash: PersistentHashMap.hash(key), key: key)
	}

	func associateKey(key: AnyObject?, value val: AnyObject) -> IPersistentMap {
		if key == nil {
			if _hasNull && val === _nullValue {
				return self
			}
			return PersistentHashMap(meta: self.meta, count: _hasNull ? _count : _count + 1, root: _root, hasNull: true, nullValue: val)
		}
		let addedLeaf: AnyObject? = nil
		let newroot: INode? = (_root ?? BitmapIndexedNode.empty).assocWithShift(0, hash: Int(Utils.hash(key)), key: key!, value: val)
		if newroot === _root {
			return self
		}
		return PersistentHashMap(meta: self.meta, count: (addedLeaf == nil) ? _count : _count + 1, root: newroot, hasNull: _hasNull, nullValue: _nullValue!)
	}

	public override func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		if let r = _root {
			if let res = r.findWithShift(0, hash: PersistentHashMap.hash(key), key: key, notFound: notFound) {
				return res
			}
		}
		return notFound
	}

	public override func objectForKey(key: AnyObject) -> AnyObject? {
		return self.objectForKey(key, def: NSNull())
	}

	func assocEx(key: AnyObject, value val: AnyObject) -> IPersistentMap {
		if self.containsKey(key) {
			fatalError("Key \(key) already present in hash map \(self)")
		}
		return self.associateKey(key, value: val)
	}

	public override func without(key: AnyObject?) -> IPersistentMap {
		if key == nil {
			return _hasNull ? PersistentHashMap(meta: self.meta, count: _count - 1, root: _root, hasNull: false, nullValue: nil) : self
		}
		if _root == nil {
			return self
		}
		let newroot: INode? = _root!.withoutWithShift(0, hash: PersistentHashMap.hash(key!), key: key!)
		if newroot === _root {
			return self
		}
		return PersistentHashMap(meta: self.meta, count: _count - 1, root: newroot, hasNull: _hasNull, nullValue: _nullValue)
	}


	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial ini: AnyObject) -> AnyObject {
		let initial = _hasNull ? f(ini, nil, _nullValue) : ini
		if Utils.isReduced(initial) {
			return (initial as! IDeref).deref
		}
		if let r = _root {
			return r.kvreduce(f, initial: initial)
		}
		return initial
	}

	public override var count : Int {
		return _count
	}

	public override var seq : ISeq {
		if let r = _root {
			return r.nodeSeq
		}
		return EmptySeq()
	}

	class var empty : IPersistentCollection {
		return EMPTY
	}

	func withMeta(meta: IPersistentMap?) -> PersistentHashMap {
		return PersistentHashMap(meta: _meta, count: _count, root: _root, hasNull: _hasNull, nullValue: _nullValue)
	}

	var meta : IPersistentMap? {
		return _meta
	}
}

