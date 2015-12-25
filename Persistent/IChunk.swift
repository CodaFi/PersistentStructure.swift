//
//  IChunk.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IChunk : IIndexed {
	func tail() -> IChunk
	func reduce(f: (AnyObject, AnyObject) -> AnyObject, start: AnyObject) -> AnyObject
}
