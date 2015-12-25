//
//  ILookup.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol ILookup {
	func objectForKey(key : AnyObject) -> AnyObject?
	func objectForKey(key : AnyObject, def : AnyObject?) -> AnyObject?
}
