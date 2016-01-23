//
//  EmptySeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class EmptySeq: AbstractSeq, IChunkedSeq {
	override var first : AnyObject? {
		return nil
	}

	override var next : ISeq {
		return self
	}

	var chunkedFirst : IChunk? {
		return nil
	}

	var chunkedNext : ISeq {
		return self
	}

	var chunkedMore : ISeq {
		return self
	}
}
