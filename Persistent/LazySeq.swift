//
//  LazySeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class LazySeq : ISeq, ISequential, IList, IPending, IHashEq {
	let _meta: IPersistentMap?

	private var _generatorFunction: (() -> AnyObject?)? = nil
	private var _secondValue: AnyObject?
	private var _backingSeq: ISeq?

	init(generator: () -> AnyObject?) {
		_meta = nil
		_generatorFunction = generator
	}

	init(meta: IPersistentMap?, seq: ISeq?) {
		_meta = meta
		_generatorFunction = nil
		_backingSeq = seq
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		return LazySeq(meta: meta, seq: self.seq)
	}

	var sval : AnyObject {
		if let gf = _generatorFunction {
			_secondValue = gf()
			_generatorFunction = nil
		}
		return _secondValue ?? _backingSeq!
	}

	var seq : ISeq {
		let _ = self.sval
		if var ls = _secondValue {
			_secondValue = nil
			while let cc = ls as? LazySeq {
				ls = cc.sval
			}
			_backingSeq = Utils.seq(ls)
		}
		guard let bs = _backingSeq else {
			fatalError("Backing Sequence not initialized correctly")
		}
		return bs
	}

	var count : Int {
		var c: Int = 0
		for _ in self.seq.generate() {
			c = c.successor()
		}
		return c
	}

	var first : AnyObject? {
		let _ = self.seq
		if let bb = _backingSeq {
			return bb.first
		}
		return nil
	}

	var next : ISeq {
		let _ = self.seq
		if let bb = _backingSeq {
			return bb.next
		}
		return EmptySeq()
	}

	var more : ISeq {
		let _ = self.seq
		if let bb = _backingSeq {
			return bb.more
		}
		return PersistentList.empty
	}

	func cons(other : AnyObject) -> IPersistentCollection {
		return Utils.cons(other, to: self.seq)
	}

	func cons(o: AnyObject) -> ISeq {
		return Utils.cons(o, to: self.seq)
	}

	var empty : IPersistentCollection {
		return PersistentList.empty
	}

	func equiv(o: AnyObject) -> Bool {
		return self.isEqual(o)
	}

	var hash : UInt {
		let s: ISeq? = self.seq
		if s == nil {
			return 1
		}
		return Utils.hash(self.seq)
	}

	var hasheq : Int {
		let s: ISeq? = self.seq
		if s == nil {
			return 1
		}
		return Utils.hasheq(self.seq)
	}

	func isEqual(other : AnyObject) -> Bool {
		if self.seq.count == 0 {
			return self.seq.equiv(other)
		} else {
			return (other is ISequential || other is IList)
		}
	}

	var toArray : Array<AnyObject> {
		return Utils.seqToArray(self.seq)
	}

	var isEmpty : Bool {
		return self.seq.count == 0
	}

	func containsObject(o: AnyObject) -> Bool {
		for e in self.seq.generate() {
			if Utils.equiv(e, other: o) {
				return true
			}
		}
		return false
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
		let s = self.seq
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

	var isRealized : Bool {
		return _generatorFunction == nil
	}
}
