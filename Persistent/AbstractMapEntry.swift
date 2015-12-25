//
//  AbstractMapEntry.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractMapEntry: AbstractPersistentVector, IMapEntry {
	override func objectAtIndex(i: Int) -> AnyObject? {
		if i == 0 {
			return self.key()
		} else if i == 1 {
			return self.val()
		} else {
			fatalError("Range or index out of bounds")
		}
	}

	func asVector() -> IPersistentVector? {
		return LazilyPersistentVector.createOwning([self.key(), self.val()]) as? IPersistentVector
	}

	override func assocN(i: Int, value val: AnyObject) -> IPersistentVector {
		return self.asVector()!.assocN(i, value: val)
	}

	override func count() -> UInt {
		return 2
	}

	override func seq() -> ISeq {
		return self.asVector()!.seq()
	}

	override func cons(o: AnyObject) -> IPersistentVector? {
		return self.asVector()!.cons(o)
	}

	override func empty() -> IPersistentCollection {
		fatalError("Collection does not admit an empty representation")
	}

	override func pop() -> IPersistentStack {
		return LazilyPersistentVector.createOwning([self.key()]) as! IPersistentStack
	}

	func setValue(value: AnyObject) -> AnyObject? {
		fatalError("setValue unimplemented")
	}

	func key() -> AnyObject {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func val() -> AnyObject {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
