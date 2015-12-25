//
//  AbstractTransientMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractTransientMap : ITransientMap {
	func ensureEditable() { }

	func doassociateKey(key: AnyObject,  val: AnyObject) -> ITransientMap {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func doWithout(key: AnyObject) -> ITransientMap {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func doobjectForKey(key: AnyObject?,  notFound: AnyObject) -> AnyObject? {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func doCount() -> Int {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func doPersistent() -> IPersistentMap {
		fatalError("\(__FUNCTION__) unimplemented")
	}

	func conj(o: AnyObject) -> ITransientCollection? {
		self.ensureEditable()
		if let e = o as? MapEntry {
			return self.associateKey(e.key()!, value: e.val()!)
		} else if let v: IPersistentVector = o as? IPersistentVector {
			if v.count() != 2 {
				fatalError("Vector arg to map conj: must be a pair")
			}
			return self.associateKey(v.objectAtIndex(0)!, value: v.objectAtIndex(1)!)
		}
		var ret: ITransientMap? = self
		for var es = Utils.seq(o); es != nil; es = es!.next() {
			let e: MapEntry = es!.first() as! MapEntry
			ret = ret!.associateKey(e.key()!, value: e.val()!)
		}
		return ret
	}

	func objectForKey(key: AnyObject) -> AnyObject? {
		self.ensureEditable()
		return self.doobjectForKey(key, notFound: NSNull())
	}

	func associateKey(key: AnyObject, value val: AnyObject) -> ITransientMap {
		self.ensureEditable()
		return self.doassociateKey(key, val: val)
	}

	func without(key: AnyObject) -> ITransientMap {
		self.ensureEditable()
		return self.doWithout(key)
	}

	func persistent() -> IPersistentCollection {
		self.ensureEditable()
		return self.doPersistent()
	}

	func persistent() -> IPersistentMap {
		self.ensureEditable()
		return self.doPersistent()
	}

	func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		self.ensureEditable()
		return self.doobjectForKey(key, notFound: notFound)!
	}

	func count() -> UInt {
		self.ensureEditable()
		return UInt(self.doCount())
	}
}
