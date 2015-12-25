//
//  Box.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class Box: NSObject {
	var _val: AnyObject?

	override init() {
		_val = nil
	}

	init(withVal val: AnyObject?) {
		_val = val
	}

	var val: AnyObject? {
		get {
			return _val
		}
		set(newVal) {
			_val = newVal
		}
	}
}