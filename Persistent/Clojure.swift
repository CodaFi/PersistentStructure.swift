//
//  Clojure.swift
//  Persistent
//
//  Created by Robert Widmann on 12/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

func CreateLazySeq(fst: AnyObject...) -> ISeq {
	return LazySeq(generator: { nil })
}

func Cons(x: AnyObject, _ seq: ISeq) -> ISeq {
	return Utils.cons(x, to: seq)
}

//func CreateList(fst: AnyObject...) -> IPersistentCollection {
//	return nil
//}

func First(coll: AnyObject) -> AnyObject {
	return Utils.first(coll)!
}

func Second(coll: AnyObject) -> AnyObject {
	return Utils.first(Utils.next(coll)!)!
}

func FFirst(coll: AnyObject) -> AnyObject {
	return Utils.first(Utils.first(coll)!)!
}

func NFirst(coll: AnyObject) -> AnyObject {
	return Utils.next(Utils.first(coll)!)!
}

func NNext(coll: AnyObject) -> AnyObject {
	return Utils.next(Utils.next(coll)!)!
}

func CreateSeq(coll: AnyObject) -> ISeq {
	return Utils.seq(coll)
}

func Count(coll: AnyObject) -> Int {
	return Utils.count(coll)
}

func ObjectAtIndex(coll: AnyObject, _ index: Int) -> AnyObject? {
	return Utils.nthOf(coll, index: index)
}

func ObjectAtIndex(coll: AnyObject, _ index: Int, _ notFound: AnyObject) -> AnyObject {
	return Utils.nthOf(coll, index: index, notFound: notFound)
}

func Contains(coll: AnyObject, _ key: AnyObject) -> Bool {
	return Utils.containsObject(coll, key: key)
}

func Next(seq: AnyObject) -> ISeq {
	return Utils.next(seq)!
}

func Rest(coll: AnyObject) -> ISeq {
	return Utils.more(coll)
}

func Conj(x: AnyObject, _ coll: IPersistentCollection) -> IPersistentCollection {
	return Utils.conj(x, to: coll)!
}

func Assoc(coll: IPersistentCollection, _ key: AnyObject, _ val: AnyObject) -> IPersistentCollection {
	return Utils.associateKey(key, to: val, into: coll as? AnyObject)
}

//func Last(coll: AnyObject) -> AnyObject {
//
//	if let nn = coll.next {
//		return Last(nn)
//	}
//	return coll.first
//}
//
//func ButLast(var coll: AnyObject) -> ISeq {
//	if var c = coll as? ISeq {
//
//		while let _ = c.next {
//			res = Utils.conj(c.first, to: c)
//			c = c.next
//		}
//		return res
//	}
//	return Utils.seq(coll)
//}
//
func CreateVector(coll: AnyObject) -> protocol<IPersistentVector, IEditableCollection> {
	if let c = coll as? ICollection {
		return LazilyPersistentVector.createOwning(c.toArray) as! protocol<IPersistentVector, IEditableCollection>
	}
	return LazilyPersistentVector.create(coll as? ICollection) as! protocol<IPersistentVector, IEditableCollection>
}

func CreateHashMap(coll: AnyObject) -> protocol<IPersistentMap, IEditableCollection> {
//	if coll.isEmpty {
//		return PersistentHashMap.empty as! protocol<IPersistentMap, IEditableCollection>
//	}
	return PersistentHashMap.create(coll as? IMap) as! protocol<IPersistentMap, IEditableCollection>
}

func CreateHashSet(coll: AnyObject) -> protocol<IPersistentSet, IEditableCollection> {
	return PersistentHashSet.createWithSeq(Utils.seq(coll))
}

func CreateSet(coll: AnyObject) -> ISet {
	return PersistentHashSet.createWithSeq(Utils.seq(coll))
}

func CreateTransient(coll: IEditableCollection) -> ITransientCollection {
	return coll.asTransient
}

//func Metadata(coll: AnyObject) -> IPersistentMap {
//	if (coll is IMeta) {
//		return coll.meta()
//	}
//	return nil
//}

func WithMetadata(obj: IObj, _ m: IPersistentMap) -> IObj {
	return obj.withMeta(m)
}
