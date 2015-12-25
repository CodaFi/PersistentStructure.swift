//
//  AbstractCons.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

final class AbstractCons : AbstractSeq {
	var _first : AnyObject
	var _more : ISeq

	init(first : AnyObject, rest : ISeq) {
		self._first = first
		self._more = rest
		super.init()
	}

	init(meta : IPersistentMap, first : AnyObject, more : ISeq) {
		self._first = first
		self._more = more
		super.init(meta: meta)
	}


	override func first() -> AnyObject? {
		return _first
	}

	override func next() -> ISeq {
		return _more.seq()
	}

	override func more() -> ISeq {
		return _more
	}

	override var count : Int {
		return 1 + Utils.count(_more)
	}

	func withMeta(meta : IPersistentMap) -> AbstractCons {
		return AbstractCons(meta: meta, first: self._first, more: self._more)
	}
}
