//
//  PersistentHashSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var EMPTY = PersistentHashSet(meta: nil, impl: PersistentHashMap.empty() as! IPersistentMap)

class PersistentHashSet: AbstractPersistentSet, IObj, IEditableCollection {
	private var _meta: IPersistentMap?

	init(meta: IPersistentMap?, impl: IPersistentMap) {
		super.init(impl: impl)
		_meta = meta
	}

	class func createWithArray(initial: Array<AnyObject>) -> PersistentHashSet {
		var ret: PersistentHashSet = EMPTY
		for var i = 0; i < initial.count; i = i.successor() {
			ret = ret.cons(initial[i]) as! PersistentHashSet
		}
		return ret
	}

	class func createWithList(initial: IList?) -> PersistentHashSet {
		var ret: PersistentHashSet = EMPTY
		for key: AnyObject in initial!.generate() {
			ret = ret.cons(key) as! PersistentHashSet
		}
		return ret
	}

	class func createWithSeq(var items: ISeq?) -> PersistentHashSet {
		var ret: PersistentHashSet = EMPTY
		for ; items != nil; items = items!.next() {
			ret = ret.cons(items!.first()!) as! PersistentHashSet
		}
		return ret
	}

	class func createWithCheckArray(initial: Array<AnyObject>) -> PersistentHashSet {
		var ret: PersistentHashSet = EMPTY
		for var i = 0; i < initial.count; i = i.successor() {
			ret = ret.cons(initial[i]) as! PersistentHashSet
			if ret.count != (i + 1) {
				fatalError("Duplicate key at index \(i)")
			}
		}
		return ret
	}

	class func createWithCheckList(initial: IList?) -> PersistentHashSet {
		var i: Int = 0
		var ret: PersistentHashSet = EMPTY
		for key: AnyObject in initial!.generate() {
			ret = ret.cons(key) as! PersistentHashSet
			if ret.count != (i + 1) {
				fatalError("Duplicate key at index \(i)")
			}
			i = i.successor()
		}
		return ret
	}

	class func createWithCheckSeq(var items: ISeq?) -> PersistentHashSet {
		var ret: PersistentHashSet = EMPTY
		for var i = 0; items != nil; items = items!.next(), i = i.successor() {
			ret = ret.cons(items!.first()!) as! PersistentHashSet
			if ret.count != (i + 1) {
				fatalError("Duplicate key at index \(i)")
			}
		}
		return ret
	}

	override func disjoin(key: AnyObject) -> IPersistentSet {
		if self.containsObject(key) {
			return PersistentHashSet(meta: self.meta(), impl: _impl.without(key))
		}
		return self
	}

	override func cons(other : AnyObject) -> IPersistentCollection {
		if self.containsObject(other) {
			return self
		}
		return PersistentHashSet(meta: self.meta(), impl: _impl.associateKey(0, withValue: other) as! IPersistentMap)
	}

	override func empty() -> IPersistentCollection {
		if let m = self.meta() {
			return EMPTY.withMeta(m) as! IPersistentCollection
		}
		return EMPTY
	}

	func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentHashSet(meta: meta, impl: _impl)
	}

	func asTransient() -> ITransientCollection {
		return TransientHashSet(impl: (_impl as! PersistentHashMap).asTransient() as! ITransientMap)
	}

	func meta() -> IPersistentMap? {
		return _meta
	}
}

