//
//  TransientArrayMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class TransientArrayMap: AbstractTransientMap {
	private var _length: Int
	private var _array: Array<AnyObject>
	private var _owner: NSThread?

	init(array: Array<AnyObject>) {
		_owner = NSThread.currentThread()
		_array = []
		_array.reserveCapacity(max(HASHTABLE_THRESHOLD, _array.count))
		ArrayCopy(array, 0, _array, 0, UInt(array.count))
		_length = array.count
	}

	func indexOf(key: AnyObject) -> Int {
		for i in 0.stride(to: _length, by: 2) {
			if TransientArrayMap.equalKey(_array[i], other: key) {
				return i
			}
		}
		return -1
	}

	class func equalKey(k1: AnyObject, other k2: AnyObject) -> Bool {
		return Utils.equiv(k1, other: k2)
	}

	override func doassociateKey(key: AnyObject,  val: AnyObject) -> ITransientMap {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			if _array[i + 1] !== val {
				_array[i + 1] = val
			}
		} else {
			if _length >= _array.count {
				let ll = PersistentHashMap.createWithMeta(nil, array: _array).asTransient
				return (ll as! IAssociative).associateKey(key, withValue: val) as! ITransientMap
			}
			_array[_length.successor()] = key
			_array[_length.successor().successor()] = val
			_length = _length.successor().successor()
		}
		return self
	}

	override func doWithout(key: AnyObject) -> ITransientMap {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			if _length >= 2 {
				_array[i] = _array[_length - 2]
				_array[i + 1] = _array[_length - 1]
			}
			_length -= 2
		}
		return self
	}

	func doobjectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		let i: Int = self.indexOf(key)
		if i >= 0 {
			return _array[i + 1]
		}
		return notFound
	}

	override func doCount() -> Int {
		return _length / 2
	}

	override func doPersistent() -> IPersistentMap {
		self.ensureEditable()
		_owner = nil
		var a: Array<AnyObject> = []
		a.reserveCapacity(_length)
		ArrayCopy(_array, 0, a, 0, UInt(_length))
		return PersistentArrayMap(initial: a)
	}

	override func ensureEditable() {
		if _owner == NSThread.currentThread() {
			return
		}
		if _owner != nil {
			fatalError("Transient used by non-owner thread")
		}
		fatalError("Transient used after call to be made persistent")
	}
}

private let HASHTABLE_THRESHOLD: Int = 16
