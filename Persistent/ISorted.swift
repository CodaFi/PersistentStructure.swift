//
//  ISorted.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol ISorted {
	var comparator : (AnyObject?, AnyObject?) -> NSComparisonResult { get }
	func entryKey(entry : AnyObject) -> AnyObject?
	func seq(ascending : Bool) -> ISeq?
	func seqFrom(key : AnyObject, ascending : Bool) -> ISeq?
}
