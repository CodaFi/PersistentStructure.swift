//
//  IAssociative.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IAssociative : IPersistentCollection, ILookup {
	func containsKey(key : AnyObject) -> Bool
	func entryForKey(key : AnyObject) -> IMapEntry?
	func associateKey(key : AnyObject, withValue value : AnyObject) -> IAssociative?
}
