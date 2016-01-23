//
//  PersistentTreeSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private let EMPTY : PersistentTreeSet = PersistentTreeSet(meta: nil, implementation: PersistentTreeMap.empty())

class PersistentTreeSet: AbstractPersistentSet, IObj, IReversible, ISorted {
	private var _meta: IPersistentMap?

	class func create(items: ISeq) -> PersistentTreeSet {
		var ret: PersistentTreeSet = EMPTY
		for entry in items.generate() {
			ret = ret.cons(entry) as! PersistentTreeSet
		}
		return ret
	}

	class func create(comparator: (AnyObject?, AnyObject?) -> NSComparisonResult, items: ISeq) -> PersistentTreeSet {
		let impl: PersistentTreeMap = PersistentTreeMap(meta: nil, comparator: comparator)
		var ret: PersistentTreeSet = PersistentTreeSet(meta: nil, implementation: impl)
		for entry in items.generate() {
			ret = ret.cons(entry) as! PersistentTreeSet
		}
		return ret
	}

	init(meta: IPersistentMap?, implementation impl: IPersistentMap) {
		super.init(impl: impl)
		_meta = meta
	}

	override func disjoin(key: AnyObject) -> IPersistentSet {
		if self.containsObject(key) {
			return PersistentTreeSet(meta: self.meta(), implementation: _impl.without(key))
		}
		return self
	}

	override func cons(other : AnyObject) -> IPersistentCollection {
		if self.containsObject(other) {
			return self
		}
		return PersistentTreeSet(meta: self.meta(), implementation: _impl.associateKey(other, withValue: other) as! IPersistentMap)
	}

	override func empty() -> IPersistentCollection {
		return PersistentTreeSet(meta: self.meta(), implementation: PersistentTreeMap.empty())
	}

	func reversedSeq() -> ISeq {
		return KeySeq(seq: (_impl as! IReversible).reversedSeq())
	}

	func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentTreeSet(meta: meta, implementation: _impl)
	}

	func comparator() -> (AnyObject?, AnyObject?) -> NSComparisonResult {
		return (_impl as! ISorted).comparator()
	}

	func entryKey(entry: AnyObject) -> AnyObject? {
		return entry
	}

	func seq(ascending: Bool) -> ISeq? {
		let m: PersistentTreeMap = _impl as! PersistentTreeMap
		return Utils.keys(m.seq(ascending)!)
	}

	func seqFrom(key: AnyObject, ascending: Bool) -> ISeq? {
		let m: PersistentTreeMap = _impl as! PersistentTreeMap
		return Utils.keys(m.seqFrom(key, ascending: ascending)!)
	}

	func meta() -> IPersistentMap? {
		return _meta
	}
}
