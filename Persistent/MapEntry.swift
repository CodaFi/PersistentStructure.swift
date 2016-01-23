//
//  MapEntry.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class MapEntry : AbstractMapEntry {
	private let _key: AnyObject?
	private let _val: AnyObject?

	override init() {
		_key = nil
		_val = nil
	}

	init(key: AnyObject, val: AnyObject) {
		_key = key
		_val = val
	}

	override var key : AnyObject {
		return _key!
	}

	override var val : AnyObject {
		return _val!
	}
}