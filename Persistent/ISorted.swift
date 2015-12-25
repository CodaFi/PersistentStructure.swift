//
//  ISorted.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol ISorted {
	func comparator() -> (AnyObject?, AnyObject?) -> NSComparisonResult
	func entryKey(entry : AnyObject) -> AnyObject?
	func seq(ascending : Bool) -> ISeq?
	func seqFrom(key : AnyObject, ascending : Bool) -> ISeq?
}
