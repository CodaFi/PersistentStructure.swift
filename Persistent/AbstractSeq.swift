//
//  AbstractSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractSeq : ISeq, ISequential, IList, IHashEq {
	private let _hash : Int
	private let _hasheq : Int
	internal let _meta : IPersistentMap?

	init() {
		_hash = -1
		_hasheq = -1
		_meta = nil
	}

	init(meta : IPersistentMap?) {
		_hash = -1
		_hasheq = -1
		_meta = meta
	}
	
	public func equiv(obj: AnyObject) -> Bool {
		if !(obj is ISequential || obj is IList) {
			return false
		}
		for (e1, e2) in zip(self.seq.generate(), Utils.seq(obj).generate()) {
			if !Utils.equiv(e1, other: e2) {
				return false
			}
		}
		return self.seq.count == Utils.seq(obj).count
	}

	public func isEqual(obj: AnyObject) -> Bool {
		if self === obj {
			return true
		}
		if !(obj is ISequential || obj is IList) {
			return false
		}
		for (e1, e2) in zip(self.seq.generate(), Utils.seq(obj).generate()) {
			if !Utils.equiv(e1, other: e2) {
				return false
			}
		}
		return self.seq.count == Utils.seq(obj).count
	}

	public var count : Int {
		var i : Int = 1;
		for var s : ISeq? = self.next; s != nil; s = s!.next, i = i.successor() {
			if let ss = s as? ICounted {
				return i + ss.count;
			}
		}
		return i;
	}

	public var hasheq : Int {
		return 0
	}

	public func lastIndexOf(other : AnyObject) -> Int {
		return -1
	}

	public func subListFromIndex(fromIndex : Int, toIndex: Int) -> IList? {
		return nil
	}

	public func containsObject(object: AnyObject) -> Bool {
		return false
	}

	public var toArray : Array<AnyObject> {
		return []
	}

	public var isEmpty : Bool {
		return true
	}

	public var seq : ISeq {
		return self
	}

	public var first : AnyObject? {
		fatalError("\(#function) unimplemented")
	}

	public var next : ISeq {
		fatalError("\(#function) unimplemented")
	}

	public var empty : IPersistentCollection {
		return PersistentList.empty
	}

	public var more : ISeq {
		if let s : ISeq = self.next {
			return s
		}
		return PersistentList.empty
	}

	public func cons(other : AnyObject) -> IPersistentCollection {
		return AbstractCons(first: other, rest: self)
	}

	public func cons(other: AnyObject) -> ISeq {
		return AbstractCons(first: other, rest: self)
	}
}
