//
//  ITransientCollection.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol ITransientCollection {
	func conj(val : AnyObject) -> ITransientCollection
	func persistent() -> IPersistentCollection
}
