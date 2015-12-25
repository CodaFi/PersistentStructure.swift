//
//  IIndexed.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IIndexed : ICounted {
	func objectAtIndex(index : Int) -> AnyObject?
	func objectAtIndex(index : Int, def : AnyObject) -> AnyObject?
}
