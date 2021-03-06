//
//  PersistentTreeSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private let EMPTY : PersistentTreeSet = PersistentTreeSet(meta: nil, implementation: PersistentTreeMap.empty())

public class PersistentTreeSet: AbstractPersistentSet, IObj, IReversible, ISorted {
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

	public override func disjoin(key: AnyObject) -> IPersistentSet {
		if self.containsObject(key) {
			return PersistentTreeSet(meta: self.meta, implementation: _impl.without(key))
		}
		return self
	}

	public override func cons(other : AnyObject) -> IPersistentCollection {
		if self.containsObject(other) {
			return self
		}
		return PersistentTreeSet(meta: self.meta, implementation: _impl.associateKey(other, withValue: other) as! IPersistentMap)
	}

	public override var empty : IPersistentCollection {
		return PersistentTreeSet(meta: self.meta, implementation: PersistentTreeMap.empty())
	}

	public var reversedSeq : ISeq {
		return KeySeq(seq: (_impl as! IReversible).reversedSeq)
	}

	public func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentTreeSet(meta: meta, implementation: _impl)
	}

	public var comparator : (AnyObject?, AnyObject?) -> NSComparisonResult {
		return (_impl as! ISorted).comparator
	}

	public func entryKey(entry: AnyObject) -> AnyObject? {
		return entry
	}

	public func seq(ascending: Bool) -> ISeq? {
		let m: PersistentTreeMap = _impl as! PersistentTreeMap
		return Utils.keys(m.seq(ascending)!)
	}

	public func seqFrom(key: AnyObject, ascending: Bool) -> ISeq? {
		let m: PersistentTreeMap = _impl as! PersistentTreeMap
		return Utils.keys(m.seqFrom(key, ascending: ascending)!)
	}

	var meta : IPersistentMap? {
		return _meta
	}
}
