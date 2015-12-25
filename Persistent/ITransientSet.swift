//
//  ITransientSet.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol ITransientSet : ITransientCollection, ICounted {
	func disjoin(key : AnyObject) -> ITransientSet
	func containsObject(key : AnyObject) -> Bool
	func objectForKey(key : AnyObject) -> AnyObject?
}
