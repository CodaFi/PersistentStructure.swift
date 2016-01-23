//
//  PersistentList.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private let EMPTY: EmptyList = EmptyList(meta: nil)

class PersistentList: AbstractSeq, IPersistentList, IReducible {
	private var _first: AnyObject
	private var _rest: IPersistentList
	private var _count: Int

	init(first: AnyObject) {
		_first = first
		_rest = EMPTY
		_count = 1
		super.init()
	}

	class var empty : ISeq {
		return EMPTY
	}

	init(meta: IPersistentMap?, first: AnyObject, rest: IPersistentList, count: Int) {
		_first = first
		_rest = rest
		_count = count
		super.init(meta: meta)
	}

	class func create(initial: IList) -> IPersistentList? {
		var ret: IPersistentList = EMPTY
		for obj in initial.generate() {
			ret = ret.cons(obj) as! IPersistentList
		}
		return ret
	}

	override var first : AnyObject {
		return _first
	}

	override var next : ISeq {
		if _count == 1 {
			return EmptySeq()
		}
		return _rest as! ISeq
	}

	var peek : AnyObject? {
		return self.first
	}

	func pop() -> IPersistentStack {
		if _rest.count != 0 {
			return _rest
		}
		return EMPTY.withMeta(_meta)
	}

	func pop() -> IPersistentList {
		if _rest.count != 0 {
			return _rest
		}
		return EMPTY.withMeta(_meta)
	}

	override var count : Int {
		return _count
	}

	func cons(o: AnyObject) -> PersistentList {
		return PersistentList(meta: _meta, first: o, rest: self, count: _count + 1)
	}

	func withMeta(meta: IPersistentMap?) -> PersistentList {
		if meta !== _meta {
			return PersistentList(meta: _meta, first: _first, rest: _rest, count: _count)
		}
		return self
	}

	func reduce(combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
		var ret: AnyObject = self.first
		for var s = self.next; s.count != 0; s = s.next {
			ret = combine(ret, s.first!)
		}
		return ret
	}

	func reduce(initial: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
		var ret: AnyObject = combine(initial, self.first)
		for var s = self.next; s.count != 0; s = s.next {
			ret = combine(ret, s.first!)
		}
		return ret
	}

	override var empty : IPersistentCollection {
		return EMPTY.withMeta(_meta)
	}
}

class EmptyList : IPersistentList, IList, ISeq, ICounted {
	private var _meta: IPersistentMap?

	init(meta: IPersistentMap?) {
		_meta = meta
	}

	func withMeta(meta: IPersistentMap?) -> EmptyList {
		if meta !== _meta {
			return EmptyList(meta: meta)
		}
		return self
	}

	var hash : UInt {
		return 1
	}

	func isEqual(other: AnyObject) -> Bool {
		return (other is ISequential
			|| other is IList)
	}

	func equiv(o: AnyObject) -> Bool {
		return self.isEqual(o)
	}

	var first : AnyObject? {
		return nil
	}

	var next : ISeq {
		return self
	}

	var more : ISeq {
		return self
	}

	func cons(o: AnyObject) -> PersistentList {
		return PersistentList(meta: _meta, first: o, rest: EMPTY, count: 1)
	}

	func cons(other : AnyObject) -> IPersistentCollection {
		return PersistentList(meta: _meta, first: other, rest: EMPTY, count: 1)
	}

	func cons(other: AnyObject) -> ISeq {
		return PersistentList(meta: _meta, first: other, rest: EMPTY, count: 1)
	}

	var empty : IPersistentCollection {
		return self
	}

	var peek : AnyObject? {
		return nil
	}

	func pop() -> IPersistentList {
		fatalError("Can't pop empty list")
	}

	func pop() -> IPersistentStack {
		fatalError("Can't pop empty list")
	}

	var count : Int {
		return 0
	}

	var seq : ISeq {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	var isEmpty : Bool {
		return true
	}

	func containsObject(o: AnyObject) -> Bool {
		return false
	}


	var toArray : Array<AnyObject> {
		return Utils._emptyArray
	}

	var reify : IList? {
		return nil
	}

	func subListFromIndex(fromIndex: Int, toIndex: Int) -> IList? {
		return self.reify!.subListFromIndex(fromIndex, toIndex: toIndex)
	}

	func set(index: Int, element: AnyObject) -> AnyObject? {
//		RequestConcreteImplementation(self, _cmd, Nil)
		return nil
	}

	func indexOf(o: AnyObject) -> Int {
		let s: ISeq = self.seq
		for (entry, i) in zip(s.generate(), 0..<s.count) {
			if Utils.equiv(entry, other: o) {
				return i
			}
		}
		return NSNotFound
	}

	func lastIndexOf(o: AnyObject) -> Int {
		return self.reify!.lastIndexOf(o)
	}

	func get(index: Int) -> AnyObject {
		return Utils.nthOf(self, index: index)!
	}
}

