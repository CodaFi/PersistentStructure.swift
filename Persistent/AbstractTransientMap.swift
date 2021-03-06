//
//  AbstractTransientMap.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class AbstractTransientMap : ITransientMap {
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

	public func conj(o: AnyObject) -> ITransientCollection {
		self.ensureEditable()
		if let e = o as? MapEntry {
			return self.associateKey(e.key, value: e.val)
		} else if let v: IPersistentVector = o as? IPersistentVector {
			guard let k1 = v.objectAtIndex(0), v1 = v.objectAtIndex(1) else {
				fatalError("Vector arg to map conj: must be a pair")
			}
			return self.associateKey(k1, value: v1)
		}
		var ret: ITransientMap = self
		for var es : ISeq = Utils.seq(o); es.count != 0; es = es.next {
			let e: MapEntry = es.first as! MapEntry
			ret = ret.associateKey(e.key, value: e.val)
		}
		return ret
	}

	public func objectForKey(key: AnyObject) -> AnyObject? {
		self.ensureEditable()
		return self.doobjectForKey(key, notFound: NSNull())
	}

	public func associateKey(key: AnyObject, value val: AnyObject) -> ITransientMap {
		self.ensureEditable()
		return self.doassociateKey(key, val: val)
	}

	public func without(key: AnyObject) -> ITransientMap {
		self.ensureEditable()
		return self.doWithout(key)
	}

	public func persistent() -> IPersistentCollection {
		self.ensureEditable()
		return self.doPersistent()
	}

	public func persistent() -> IPersistentMap {
		self.ensureEditable()
		return self.doPersistent()
	}

	public func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		self.ensureEditable()
		return self.doobjectForKey(key, notFound: notFound)!
	}

	public var count : Int {
		self.ensureEditable()
		return self.doCount()
	}
}
