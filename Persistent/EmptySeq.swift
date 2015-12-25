//
//  EmptySeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class EmptySeq: AbstractSeq {
	override func first() -> AnyObject? {
		return nil
	}

	override func next() -> ISeq? {
		return self
	}
}
