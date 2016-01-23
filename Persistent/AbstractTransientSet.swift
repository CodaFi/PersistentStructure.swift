//
//  AbstractTransientSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractTransientSet : ITransientSet {
	var _impl: ITransientMap

	init(impl: ITransientMap) {
		_impl = impl
	}

	public var count : Int {
		return _impl.count
	}

	public func conj(val: AnyObject) -> ITransientCollection {
		let m: ITransientMap = _impl.associateKey(val, value: val)
		if m !== _impl {
			_impl = m
		}
		return self
	}

	public func containsObject(key: AnyObject) -> Bool {
		return self !== _impl.objectForKey(key, def: self) as! AbstractTransientSet
	}

	public func disjoin(key: AnyObject) -> ITransientSet {
		let m: ITransientMap = _impl.without(key)
		if m !== _impl {
			_impl = m
		}
		return self
	}

	public func objectForKey(key: AnyObject) -> AnyObject? {
		return _impl.objectForKey(key)!
	}

	public func persistent() -> IPersistentCollection {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
