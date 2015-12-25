//
//  IPersistentMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IPersistentMap : class, IAssociative, ICounted {
	func associateEx(key : AnyObject, value : AnyObject) -> IPersistentMap
	func without(key : AnyObject) -> IPersistentMap
}
