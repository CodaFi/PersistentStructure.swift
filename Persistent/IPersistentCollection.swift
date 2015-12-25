//
//  IPersistentCollection.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IPersistentCollection : ISeqable {
	func count() -> UInt
	func cons(other : AnyObject) -> IPersistentCollection?
	func empty() -> IPersistentCollection
	func equiv(o : AnyObject) -> Bool
}
