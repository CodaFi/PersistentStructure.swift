//
//  AbstractMapEntry.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractMapEntry: AbstractPersistentVector, IMapEntry {
	public override func objectAtIndex(i: Int) -> AnyObject? {
		if i == 0 {
			return self.key
		} else if i == 1 {
			return self.val
		} else {
			fatalError("Range or index out of bounds")
		}
	}

	var asVector : IPersistentVector {
		return LazilyPersistentVector.createOwning([self.key, self.val]) 
	}

	public override func assocN(i: Int, value val: AnyObject) -> IPersistentVector {
		return self.asVector.assocN(i, value: val)
	}

	public override var count : Int {
		return 2
	}

	public override var seq : ISeq {
		return self.asVector.seq
	}

	public override func cons(o: AnyObject) -> IPersistentVector {
		return self.asVector.cons(o)
	}

	public override var empty : IPersistentCollection {
		fatalError("Collection does not admit an empty representation")
	}

	public override func pop() -> IPersistentStack {
		return LazilyPersistentVector.createOwning([self.key])
	}

	public func setValue(value: AnyObject) -> AnyObject? {
		fatalError("setValue unimplemented")
	}

	public var key : AnyObject {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	public var val : AnyObject {
		fatalError("\(__FUNCTION__) unimplemented")
	}
}
