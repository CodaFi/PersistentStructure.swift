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
	var allEntries : ISet { get }
	var isEmpty : Bool { get }
	var allKeys : ISet { get }
	var count: Int { get }
	var values : ICollection { get }
}
