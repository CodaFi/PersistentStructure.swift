//
//  Obj.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class Obj: IObj, IMeta {
	private let _meta: IPersistentMap?

	init(meta: IPersistentMap?) {
		_meta = meta
	}

	public var meta : IPersistentMap? {
		return _meta
	}

	public func withMeta(meta: IPersistentMap?) -> IObj {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}