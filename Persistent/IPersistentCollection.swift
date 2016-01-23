//
//  IPersistentCollection.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IPersistentCollection : ISeqable {
	var count : Int { get }
	func cons(other : AnyObject) -> IPersistentCollection
	var empty : IPersistentCollection { get }
	func equiv(o : AnyObject) -> Bool
}
