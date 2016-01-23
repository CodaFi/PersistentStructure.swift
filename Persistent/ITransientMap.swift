//
//  ITransientMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol ITransientMap : class, ITransientAssociative, ICounted {
	func associateKey(key: AnyObject, value: AnyObject) -> ITransientMap
	func without(key : AnyObject) -> ITransientMap
	func persistent() -> IPersistentMap 
}
