//
//  KeySeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class KeySeq : AbstractSeq {
	private var _seq: ISeq

	init(seq: ISeq) {
		_seq = seq
		super.init()
	}

	init(meta: IPersistentMap?, seq: ISeq) {
		_seq = seq
		super.init(meta: meta)
	}

	override func first() -> AnyObject? {
		return (_seq.first as! IMapEntry).key()
	}

	override func next() -> ISeq {
		return KeySeq(seq: _seq.next())
	}

	func withMeta(meta: IPersistentMap?) -> KeySeq {
		return KeySeq(meta: meta, seq: _seq)
	}
}