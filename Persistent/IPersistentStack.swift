//
//  IPersistentStack.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IPersistentStack : IPersistentCollection {
	func peek() -> AnyObject?
	func pop() -> IPersistentStack?
}
