//
//  LazilyPersistentVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class LazilyPersistentVector {
	class func createOwning(items: Array<AnyObject>) -> IPersistentVector {
		if items.count == 0 {
			return PersistentVector.empty()
		} else if items.count <= 32 {
			return PersistentVector(cnt: items.count, shift: 5, root: (PersistentVector.emptyNode as? INode)!, tail: items)
		}
		return PersistentVector.createWithItems(items)
	}

	class func create(coll: ICollection?) -> IPersistentVector {
		if !(coll is ISeq) && coll!.count <= 32 {
			return LazilyPersistentVector.createOwning(coll!.toArray())
		}
		return PersistentVector.createWithSeq(Utils.seq(coll!))
	}
}
