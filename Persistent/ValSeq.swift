//
//  ValSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class ValSeq: AbstractSeq {
	private var _seq: ISeq?

	init(seq: ISeq?) {
		_seq = seq
		super.init()
	}

	init(meta: IPersistentMap?, seq: ISeq?) {
		_seq = seq
		super.init(meta: meta)
	}

	override func first() -> AnyObject? {
		return (_seq!.first() as! IMapEntry).val()
	}

	override func next() -> ISeq {
		return ValSeq.create(_seq!.next())
	}

	func withMeta(meta: IPersistentMap?) -> ValSeq? {
		return ValSeq(meta: meta, seq: _seq)
	}

	class func create(seq: ISeq) -> ValSeq {
		return ValSeq(seq: seq)
	}
}
