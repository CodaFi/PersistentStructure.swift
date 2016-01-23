//
//  ISeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol ISeq : class, IPersistentCollection {
	func first() -> AnyObject?
	func next() -> ISeq
	func more() -> ISeq
	func cons(other: AnyObject) -> ISeq
}

extension ISeq {
	typealias Generator = IndexingGenerator<Array<AnyObject>>
	
	func generate() -> IndexingGenerator<Array<AnyObject>> {
		return Utils.seqToArray(self).generate()
	}
}
