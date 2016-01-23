//
//  INode.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import Darwin

protocol INode : class {
	func assocWithShift(shift : Int, hash : Int, key : AnyObject, value : AnyObject) -> INode?
	func withoutWithShift(shift : Int, hash : Int, key : AnyObject) -> INode?
	func findWithShift(shift : Int, hash : Int, key : AnyObject) -> IMapEntry?
	func findWithShift(shift : Int, hash : Int, key : AnyObject, notFound : AnyObject) -> AnyObject?
	func nodeSeq() -> ISeq
	func assocOnThread(edit : NSThread?, shift : Int, hash : Int, key : AnyObject, val : AnyObject) -> INode?
	func withoutOnThread(edit : NSThread?, shift : Int, hash : Int, key : AnyObject) -> INode?
	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial: AnyObject) -> AnyObject
	
//	- (id)kvreduce:(IKeyValueReduceBlock)f init:(id)init;
}
