//
//  IMapEntry.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IMapEntry : class {
	func key() -> AnyObject?
	func val() -> AnyObject?

	func isEqual(o : AnyObject) -> Bool
	func setValue(value : AnyObject) -> AnyObject?
}
