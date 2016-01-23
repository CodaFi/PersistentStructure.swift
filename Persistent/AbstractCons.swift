//
//  AbstractCons.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public final class AbstractCons : AbstractSeq {
	let _first : AnyObject
	let _more : ISeq

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


	public override var first : AnyObject? {
		return _first
	}

	public override var next : ISeq {
		return _more.seq
	}

	public override var more : ISeq {
		return _more
	}

	public override var count : Int {
		return 1 + Utils.count(_more)
	}

	func withMeta(meta : IPersistentMap) -> AbstractCons {
		return AbstractCons(meta: meta, first: self._first, more: self._more)
	}
}
