//
//  AbstractSequence.swift
//  PersistentStructure
//
//  Created by Robert Widmann on 6/29/14.
//  Copyright (c) 2014 CodaFi. All rights reserved.
//

import Foundation

class AbstractSequence<T> : ISequence, ISequentialAccess, IHashEqable, ISeqable {
	typealias Element = T
	
	var _meta : IPersistentMap
	var _hash : Int
	var _hasheq : Int
	
	init() {
		_hash = -1
		_hasheq = -1
	}
	
	init(meta: IPersistentMap) {
		_meta = meta
	}
	
	func count() -> UInt {
		var i : UInt = 1
		for var s = next(); s != nil; s = s?.next(), i++ {
			if let el as ICounted {
				return i + el.count()
			}
		}
		return i
	}
	
	func seq() -> ISequence {
		return self
	}
	
	func cons(value: T) -> ISequence {
		return AbstractCons(first: value, rest: self)
	}
	
	func cons(value: T) -> IPersistentCollection {
		return AbstractCons(first: value, rest: self)
	}
	
	func empty() -> IPersistentCollection {
		//	return CLJPersistentList.empty;
	}
	
	func more() -> ISequence?  {
		if let s = self.next() {
			return s
		}
		// return CLJPersistentList.empty;
	}
	
	func first() -> T?  {
		return nil
	}
	
	func next() -> ISequence?  {
		return nil
	}
	
	func hasheq() -> Int {
		if _hasheq == -1 {
			var hash : Int = 1
			for var s = seq(); s != nil; s = s.next()! {
				hash = 31 * hash + (s?.first() == nil ? 0 : s.first()!.hash)
			}
			_hasheq = hash
		}
		return _hasheq
	}
}