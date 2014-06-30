//
//  AbstractCons.swift
//  PersistentStructure
//
//  Created by Robert Widmann on 6/29/14.
//  Copyright (c) 2014 CodaFi. All rights reserved.
//

import Foundation

class AbstractCons<T> : AbstractSequence<T>, IObject {
	var _first : T
	var _more : ISequence?
	
	init(first: T, rest: ISequence) {
		_first = first
		_more = rest
		super.init()
	}
	
	init(meta: IPersistentMap, first: T, rest: ISequence) {
		self._first = first
		self._more = rest
		super.init(meta: meta)
	}
	
	override func first() -> T {
		return self._first
	}
	
	override func next() -> ISequence?  {
		return _more?.seq()
	}
	
	override func more() -> ISequence?  {
		if let m = self._more?  {
			return self._more
		}
		// return CLJPersistentList.empty;
	}
	
	override func count() -> UInt {
		return 1 + [CLJUtils count:_more];
	}
	
	func withMeta(meta: IPersistentMap) -> AbstractCons<T> {
		return AbstractCons<T>(meta: meta, first: _first, rest: _more!)
	}
}

