//
//  IChunk.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IChunk : IIndexed {
	var tail : IChunk { get }
	func reduce(f: (AnyObject, AnyObject) -> AnyObject, start: AnyObject) -> AnyObject
}
