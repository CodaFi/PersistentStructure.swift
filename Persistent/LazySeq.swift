//
//  LazySeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class LazySeq : ISeq, ISequential, IList, IPending, IHashEq {
	var _meta: IPersistentMap?

	private var _generatorFunction: (() -> AnyObject?)? = nil
	private var _secondValue: AnyObject?
	private var _backingSeq: ISeq?

	init(g: () -> AnyObject?) {
		_generatorFunction = g
	}

	init(meta: IPersistentMap?, seq: ISeq?) {
		_meta = meta
		_generatorFunction = nil
		_backingSeq = seq
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		return LazySeq(meta: meta, seq: self.seq())
	}

	func sval() -> AnyObject {
		if _generatorFunction != nil {
			_secondValue = _generatorFunction!()!
			_generatorFunction = nil
		}
		if _secondValue != nil {
			return _secondValue!
		}
		return _backingSeq!
	}

	func seq() -> ISeq {
		let _ = self.sval()
		if _secondValue != nil {
			var ls : AnyObject = _secondValue!
			_secondValue = nil
			while let cc = ls as? LazySeq {
				ls = cc.sval()
			}
			_backingSeq = Utils.seq(ls)
		}
		guard let bs = _backingSeq else {
			fatalError("Backing Sequence not initialized correctly")
		}
		return bs
	}

	func count() -> UInt {
		var c: UInt = 0
		for var s = self.seq(); s.count() != 0; s = s.next() {
			c = c.successor()
		}
		return c
	}

	func first() -> AnyObject? {
		let _ = self.seq()
		if let bb = _backingSeq {
			return bb.first()
		}
		return nil
	}

	func next() -> ISeq {
		let _ = self.seq()
		if let bb = _backingSeq {
			return bb.next()
		}
		return EmptySeq()
	}

	func more() -> ISeq {
		let _ = self.seq()
		if let bb = _backingSeq {
			return bb.more()
		}
		return PersistentList.empty()
	}

	func cons(other : AnyObject) -> IPersistentCollection {
		return Utils.cons(other, to: self.seq())
	}

	func cons(o: AnyObject) -> ISeq {
		return Utils.cons(o, to: self.seq())
	}

	func empty() -> IPersistentCollection {
		return PersistentList.empty()
	}

	func equiv(o: AnyObject) -> Bool {
		return self.isEqual(o)
	}

	func hash() -> UInt {
		let s: ISeq? = self.seq()
		if s == nil {
			return 1
		}
		return Utils.hash(self.seq())
	}

	func hasheq() -> Int {
		let s: ISeq? = self.seq()
		if s == nil {
			return 1
		}
		return Utils.hasheq(self.seq())
	}

	func isEqual(other : AnyObject) -> Bool {
		if self.seq().count() == 0 {
			return self.seq().equiv(other)
		} else {
			return (other is ISequential || other is IList)
		}
	}

	func toArray() -> Array<AnyObject> {
		return Utils.seqToArray(self.seq())
	}

	func isEmpty() -> Bool {
		return self.seq().count() == 0
	}

	func containsObject(o: AnyObject) -> Bool {
		for var s = self.seq(); s.count() != 0; s = s.next() {
			if Utils.equiv(s.first(), other: o) {
				return true
			}
		}
		return false
	}

	func objectEnumerator() -> NSEnumerator {
		return SeqIterator(seq: self.seq())
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

	func isRealized() -> Bool {
		return _generatorFunction == nil
	}
}
