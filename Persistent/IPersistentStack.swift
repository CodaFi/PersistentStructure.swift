//
//  IPersistentStack.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IPersistentStack : IPersistentCollection {
	var peek : AnyObject? { get }
	func pop() -> IPersistentStack
}
