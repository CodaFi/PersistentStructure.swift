//
//  ISeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol ISeq : class, IPersistentCollection {
	var first : AnyObject? { get }
	var next : ISeq { get } 
	var more : ISeq { get }
	func cons(other: AnyObject) -> ISeq
}

extension ISeq {
	typealias Generator = IndexingGenerator<Array<AnyObject>>
	
	func generate() -> IndexingGenerator<Array<AnyObject>> {
		return Utils.seqToArray(self).generate()
	}
}
