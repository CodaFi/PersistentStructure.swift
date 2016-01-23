//
//  Reduced.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class Reduced : IDeref {
	private var _val: AnyObject

	init(val: AnyObject) {
		_val = val
	}

	var deref : AnyObject {
		return _val
	}
}
