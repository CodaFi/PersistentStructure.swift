//
//  StringSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class StringSeq: AbstractSeq, IIndexedSeq {
	private var _string: NSString
	private var _index: Int

	convenience init(s: NSString) {
		self.init(meta: nil, string: s, index: 0)
	}

	init(meta: IPersistentMap?, string: NSString, index: Int) {
		_string = string
		_index = index
		super.init(meta: meta)
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		if meta === _meta {
			return self
		}
		return StringSeq(meta: meta, string: _string, index: _index)
	}

	override func first() -> AnyObject {
		return NSNumber(unsignedShort: _string.characterAtIndex(_index))
	}

	override func next() -> ISeq {
		if _index + 1 < _string.length {
			return StringSeq(meta: _meta, string: _string, index: _index + 1)
		}
		return EmptySeq()
	}

	func index() -> Int {
		return _index
	}

	override var count : Int {
		return _string.length - _index
	}
}
