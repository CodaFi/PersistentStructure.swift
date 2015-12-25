//
//  Obj.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class Obj: IObj, IMeta {
	private var _meta: IPersistentMap?

	init(meta: IPersistentMap?) {
		_meta = meta
	}

	func meta() -> IPersistentMap? {
		return _meta
	}

	func withMeta(meta: IPersistentMap) -> IObj {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}