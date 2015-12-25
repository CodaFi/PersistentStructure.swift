//
//  AbstractTransientSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractTransientSet : ITransientSet {
	var _impl: ITransientMap

	init(impl: ITransientMap) {
		_impl = impl
	}

	func count() -> UInt {
		return _impl.count()
	}

	func conj(val: AnyObject) -> ITransientCollection {
		let m: ITransientMap = _impl.associateKey(val, value: val)
		if m !== _impl {
			_impl = m
		}
		return self
	}

	func containsObject(key: AnyObject) -> Bool {
		return self !== _impl.objectForKey(key, def: self) as! AbstractTransientSet
	}

	func disjoin(key: AnyObject) -> ITransientSet {
		let m: ITransientMap = _impl.without(key)
		if m !== _impl {
			_impl = m
		}
		return self
	}

	func objectForKey(key: AnyObject) -> AnyObject? {
		return _impl.objectForKey(key)!
	}

	func persistent() -> IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
