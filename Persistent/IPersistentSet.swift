//
//  IPersistentSet.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IPersistentSet : class, IPersistentCollection, ICounted {
	func disjoin(key : AnyObject) -> IPersistentSet
	func containsObject(key : AnyObject) -> Bool
	func objectForKey(key : AnyObject) -> AnyObject
}
