//
//  AbstractTransientMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class AbstractTransientMap: NSObject, ITransientMap {
	func ensureEditable() {

	}

	func doassociateKey(key: AnyObject,  val: AnyObject) -> ITransientMap? {
		return nil
	}

	func doWithout(key: AnyObject) -> ITransientMap? {
		return nil
	}

	func doobjectForKey(key: AnyObject?,  notFound: AnyObject) -> AnyObject? {
		return nil
	}

	func doCount() -> Int {
		return 0
	}

	func doPersistent() -> IPersistentMap? {
		return nil
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
		return self.objectForKey(key, def: nil)
	}

	func associateKey(key: AnyObject, value val: AnyObject) -> ITransientMap? {
		self.ensureEditable()
		return self.doassociateKey(key, val: val)
	}

	func without(key: AnyObject) -> ITransientMap? {
		self.ensureEditable()
		return self.doWithout(key)
	}

	func persistent() -> IPersistentCollection? {
		self.ensureEditable()
		return self.doPersistent()
	}

	func persistent() -> IPersistentMap? {
		self.ensureEditable()
		return self.doPersistent()
	}

	func objectForKey(key: AnyObject, def notFound: AnyObject?) -> AnyObject? {
		self.ensureEditable()
		return self.doobjectForKey(key, notFound: notFound!)!
	}

	func count() -> UInt {
		self.ensureEditable()
		return UInt(self.doCount())
	}
}
