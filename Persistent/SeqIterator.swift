//
//  SeqIterator.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class SeqIterator: NSEnumerator {
	private var _seq: ISeq

	init(seq: ISeq) {
		_seq = seq
	}

	override func nextObject() -> AnyObject {
		let ret: AnyObject = Utils.first(_seq)!
		_seq = Utils.next(_seq)!
		return ret
	}
}
