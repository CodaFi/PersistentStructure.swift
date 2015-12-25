//
//  MapEntry.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class MapEntry : AbstractMapEntry {
	private var _key: AnyObject? = nil
	private var _val: AnyObject? = nil

	override init() {

	}

	init(key: AnyObject, val: AnyObject) {
		_key = key
		_val = val
	}

	override func key() -> AnyObject {
		return _key!
	}

	override func val() -> AnyObject {
		return _val!
	}
}