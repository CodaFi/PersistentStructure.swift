//
//  Node.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class Node : NSObject {
	init(edit: NSThread?) {
		_edit = edit
		_array = Array<AnyObject>()
		_array.reserveCapacity(32)
	}

	init(edit: NSThread?, array: Array<AnyObject>) {
		_edit = edit
		_array = array
	}

	private(set) var _edit: NSThread?
	var edit : NSThread? {
		return _edit
	}
	private(set) var _array: Array<AnyObject>
	var array : Array<AnyObject> {
		get {
			return _array
		}
		set(newArray) {
			_array = newArray
		}
	}
}