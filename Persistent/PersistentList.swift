//
//  PersistentList.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var EMPTY: EmptyList = EmptyList(meta: nil)

class PersistentList: AbstractSeq, IPersistentList, IReducible {
	private var _first: AnyObject
	private var _rest: IPersistentList?
	private var _count: Int

	init(first: AnyObject) {
		_first = first
		_rest = nil
		_count = 1
		super.init()
	}

	class func empty() -> ISeq {
		return EMPTY
	}

	class func empty() -> IPersistentCollection? {
		return EMPTY
	}

	init(meta: IPersistentMap?, first: AnyObject, rest: IPersistentList?, count: Int) {
		_first = first
		_rest = rest
		_count = count
		super.init(meta: meta)
	}

	class func create(initial: IList?) -> IPersistentList? {
		var ret: IPersistentList? = EMPTY
		let it: NSEnumerator = initial!.objectEnumerator()
		var obj: AnyObject? = it.nextObject()
		while obj != nil {
			ret = ret!.cons(obj!) as? IPersistentList
			obj = it.nextObject()
		}
		return ret
	}

	override func first() -> AnyObject {
		return _first
	}

	override func next() -> ISeq {
		if _count == 1 {
			return EmptySeq()
		}
		return _rest as! ISeq
	}

	func peek() -> AnyObject? {
		return self.first()
	}

	func pop() -> IPersistentStack? {
		if _rest == nil {
			return EMPTY.withMeta(_meta)
		}
		return _rest
	}

	func pop() -> IPersistentList? {
		if _rest == nil {
			return EMPTY.withMeta(_meta)
		}
		return _rest
	}

	override func count() -> UInt {
		return UInt(_count)
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
		var ret: AnyObject = self.first()
		for var s = self.next(); s.count() != 0; s = s.next() {
			ret = combine(ret, s.first()!)
		}
		return ret
	}

	func reduce(initial: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
		var ret: AnyObject = combine(initial, self.first())
		for var s = self.next(); s.count() != 0; s = s.next() {
			ret = combine(ret, s.first()!)
		}
		return ret
	}

	override func empty() -> IPersistentCollection? {
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

	func hash() -> UInt {
		return 1
	}

	func isEqual(other: AnyObject?) -> Bool {
		if let o = other {
			return (o is ISequential
				|| o is IList)
				&& Utils.seq(o) == nil
		}
		return false
	}

	func equiv(o: AnyObject) -> Bool {
		return self.isEqual(o)
	}

	func first() -> AnyObject? {
		return nil
	}

	func next() -> ISeq {
		return self
	}

	func more() -> ISeq {
		return self
	}

	func cons(o: AnyObject) -> PersistentList {
		return PersistentList(meta: _meta, first: o, rest: nil, count: 1)
	}

	func cons(other : AnyObject) -> IPersistentCollection? {
		return PersistentList(meta: _meta, first: other, rest: nil, count: 1)
	}

	func cons(other: AnyObject) -> ISeq {
		return PersistentList(meta: _meta, first: other, rest: nil, count: 1)
	}

	func empty() -> IPersistentCollection? {
		return self
	}

	func peek() -> AnyObject? {
		return nil
	}

	func pop() -> IPersistentList? {
		fatalError("Can't pop empty list")
	}

	func pop() -> IPersistentStack? {
		fatalError("Can't pop empty list")
	}

	func count() -> UInt {
		return 0
	}

	func seq() -> ISeq {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func isEmpty() -> Bool {
		return true
	}

	func containsObject(o: AnyObject) -> Bool {
		return false
	}

	func objectEnumerator() -> NSEnumerator {
		return NSEnumerator()
	}

	func toArray() -> Array<AnyObject> {
		return Utils._emptyArray()
	}

	func reify() -> IList? {
		return nil
	}

	func subListFromIndex(fromIndex: Int, toIndex: Int) -> IList? {
		return self.reify()!.subListFromIndex(fromIndex, toIndex: toIndex)
	}

	func set(index: Int, element: AnyObject) -> AnyObject? {
//		RequestConcreteImplementation(self, _cmd, Nil)
		return nil
	}

	func indexOf(o: AnyObject) -> Int {
		var s: ISeq? = self.seq()
		for var i = 0; s != nil; s = s!.next(), i = i.successor() {
			if Utils.equiv(s!.first(), other: o) {
				return i
			}
		}
		return NSNotFound
	}

	func lastIndexOf(o: AnyObject) -> Int {
		return self.reify()!.lastIndexOf(o)
	}

	func get(index: Int) -> AnyObject {
		return Utils.nthOf(self, index: index)!
	}

	func countByEnumeratingWithState(state: UnsafeMutablePointer<NSFastEnumerationState>, objects buffer: AutoreleasingUnsafeMutablePointer<AnyObject?>, count len: Int) -> Int {
		return 0
	}
}

