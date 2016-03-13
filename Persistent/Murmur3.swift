//
//  Murmur3.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import Darwin

class Murmur3: NSObject {
	class func hashOrdered(xs: ICollection) -> UInt {
		var n: UInt = 0
		var hash: UInt = 1
		for x: AnyObject in xs.generate() {
			hash = 31 * hash + UInt(Utils.hasheq(x))
			n = n.successor()
		}
		return Murmur3.mixCollHash(hash, count: n)
	}

	class func hashUnordered(xs: ICollection) -> UInt {
		var hash: UInt = 0
		var n: UInt = 0
		for x: AnyObject in xs.generate() {
			hash += UInt(Utils.hasheq(x))
			n = n.successor()
		}
		return Murmur3.mixCollHash(hash, count: n)
	}

	class func mixCollHash(hash: UInt, count: UInt) -> UInt {
		var outhash: UInt = 0
		let buffer = UnsafeMutablePointer<CChar>.alloc(65)
//		buffer.initialize(hash)
		MurmurHash3_x86_128(buffer, 65, 0, &outhash)
		return outhash
	}
}
