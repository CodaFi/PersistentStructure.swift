//
//  ICollection.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol ICollection : class, ICounted {
	func containsObject(object : AnyObject) -> Bool
	var toArray : Array<AnyObject> { get }
	var isEmpty : Bool { get }
}

extension ICollection {
	typealias Generator = IndexingGenerator<Array<AnyObject>>

	func generate() -> IndexingGenerator<Array<AnyObject>> {
		return self.toArray.generate()
	}
}
