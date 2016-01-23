//
//  IList.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IList : ICollection {
	func isEqual(other : AnyObject) -> Bool
	func lastIndexOf(other : AnyObject) -> Int
	func subListFromIndex(fromIndex : Int, toIndex: Int) -> IList?
}
