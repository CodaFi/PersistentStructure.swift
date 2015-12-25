//
//  IMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IMap {
	func objectForKey(key: AnyObject) -> AnyObject?
	func setObject(val: AnyObject, forKey key: AnyObject) -> AnyObject?

	func containsKey(key: AnyObject) -> Bool
	func containsValue(value: AnyObject) -> Bool
	func allEntries() -> ISet
	var isEmpty : Bool { get }
	func allKeys() -> ISet
	var count: Int { get }
	func values() -> ICollection
}
