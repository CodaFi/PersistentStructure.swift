//
//  ITransientAssociative.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol ITransientAssociative : ITransientCollection, ILookup {
	func associateKey(key: AnyObject, value val: AnyObject) -> ITransientMap
}
