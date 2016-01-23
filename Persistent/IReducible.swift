//
//  IReducible.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IReducible {
	func reduce(combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject
	func reduce(initial: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject
}
