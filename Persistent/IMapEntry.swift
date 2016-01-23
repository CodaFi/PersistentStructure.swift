//
//  IMapEntry.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IMapEntry : class {
	var key : AnyObject { get }
	var val : AnyObject { get }

	func isEqual(o : AnyObject) -> Bool
	func setValue(value : AnyObject) -> AnyObject?
}
