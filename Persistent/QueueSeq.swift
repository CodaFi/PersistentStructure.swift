//
//  QueueSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class QueueSeq: AbstractSeq {
	private var _f: ISeq
	private var _rseq: ISeq

	init(f: ISeq, rev rseq: ISeq) {
		_f = f
		_rseq = rseq
		super.init()
	}

	init(meta: IPersistentMap?, first f: ISeq, rev rseq: ISeq) {
		_f = f
		_rseq = rseq
		super.init(meta: meta)
	}

	override var first : AnyObject? {
		return _f.first
	}

	override var next : ISeq {
		var f1: ISeq = _f.next
		var r1: ISeq = _rseq
		if f1.count == 0 {
			if _rseq.count == 0 {
				return EmptySeq()
			}
			f1 = _rseq
			r1 = EmptySeq()
		}
		return QueueSeq(f: f1, rev: r1)
	}

	override var count : Int {
		return Utils.count(_f) + Utils.count(_rseq)
	}

	func withMeta(meta: IPersistentMap?) -> ISeq? {
		return QueueSeq(meta: meta, first: _f, rev: _rseq)
	}
}
