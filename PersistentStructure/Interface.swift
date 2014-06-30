//
//  Interface.swift
//  PersistentStructure
//
//  Created by Robert Widmann on 6/29/14.
//  Copyright (c) 2014 CodaFi. All rights reserved.
//

import Foundation

protocol IAssociative : IPersistentCollection, ILookup {
	func containsKey(key: AnyObject) -> Bool
	func entryForKey(key: AnyObject) -> IMapEntry
	func associate(key: AnyObject, val: AnyObject) -> IAssociative
}

protocol IChunk : IIndexed {
	func tail() -> IChunk
	func reduce<T>(f : T -> T -> T, start: T) -> T
}

protocol IChunkedSequence : ISequence, ISequentialAccess {
	func chunkedFirst() -> IChunk
	func chunkedNext() -> ISequence
	func chunkedMore() -> ISequence
}

protocol ICollection : ICounted {
	
}

protocol IComparable : Comparable {}

protocol ICounted {
	func count() -> UInt
}

protocol IDeref {
	typealias T
	func deref() -> T
}

protocol IEditableCollection {
	func asTransient() -> ITransientCollection
}

protocol IHashEqable {
	func hasheq() -> Int
}

protocol IIndexed : ICounted {
	typealias Element
	subscript (i: Int) -> AnyObject? { get }
}

protocol IIndexedSequence : ISequence, ISequentialAccess, ICounted {
	func index() -> Int
}

protocol ILookup {
	typealias Key
	typealias Element
	subscript (i: Key) -> AnyObject? { get }
}

protocol IMapEntry : Equatable {
	typealias Key
	typealias Value
	
	var key : Key { get }
	var value : Value { get }
}


protocol IMetable {
	func meta() -> IPersistentMap;
}

protocol INode {
	func assoc(shift: Int, hash: Int, key: AnyObject, value: AnyObject, addedLeaf: AnyObject?) -> INode
	func without(shift: Int, hash: Int, key: AnyObject) -> INode
	func find(shift: Int, hash: Int, key: AnyObject) -> IMapEntry
	func find(shift: Int, hash: Int, key: AnyObject, notFound: AnyObject) -> AnyObject
	func nodeSequence() -> ISequence;
	
	func assoc(edit: NSThread!, shift: Int, hash: Int, key: AnyObject, value: AnyObject, addedLeaf: AnyObject?) -> INode
	func without(edit: NSThread!, shift: Int, hash: Int, key: AnyObject) -> INode
	
//	func Object kvreduce(IFn f, Object init);
//	
//	Object fold(IFn combinef, IFn reducef, IFn fjtask, IFn fjfork, IFn fjjoin);
}

protocol IObject {
	func withMeta(meta: IPersistentMap) -> Self
}

protocol IPending {
	func isRealized() -> Bool
}

protocol IPersistentCollection : ISeqable, ICounted {
	typealias Element
	func cons(other: Element) -> IPersistentCollection
	func empty() -> IPersistentCollection
//	- (BOOL)equiv:(id)o;
}

protocol IPersistentList : ISequentialAccess, IPersistentStack {
	
}

protocol IPersistentMap : IAssociative, ICounted {
	func associate(key: AnyObject, value: AnyObject) -> IPersistentMap
	func assocEx(key: AnyObject, value: AnyObject) -> IPersistentMap
	func without(key: AnyObject) -> IPersistentMap
}

protocol IPersistentSet : IPersistentCollection, ICounted {
	typealias Key
	typealias Element
	func disjoin(key: AnyObject) -> IPersistentSet
	func containsObject(key: AnyObject) -> Bool;
	subscript (i: Key) -> AnyObject? { get }
}

protocol IPersistentStack : IPersistentCollection {
	func peek() -> AnyObject
	func pop() -> IPersistentStack
}

protocol IPersistentVector : IAssociative, ISequentialAccess, IPersistentStack, IReversible, IIndexed {
	func assocN(index: Int, value: AnyObject) -> IPersistentVector
	func cons(value: AnyObject) -> IPersistentVector
}

protocol IRandomAccess {}

protocol IReducible {
	func reduce<T>(f : T -> T -> T) -> T
	func reduce<T>(f : T -> T -> T, start: T) -> T
}

protocol IReversible {
	func reversedSeq() -> ISequence?
}

protocol ISequence : IPersistentCollection {
	typealias Element
	func first() -> Element?
	func next() -> ISequence?
	func more() -> ISequence?
	func cons(value: Element) -> ISequence
}

protocol ISeqable {
	func seq() -> ISequence
}

protocol ISequentialAccess {}

protocol ISet : ICollection {
	
}

protocol ISorted {
	func comparator<T : Comparable>() -> (T -> T -> NSComparisonResult)
	func entryKey(entry: AnyObject) -> AnyObject
	func seq(ascending: Bool) -> ISequence
	func seq(key: AnyObject, ascending: Bool) -> ISequence
}

protocol ITransientAssociative : ITransientCollection, ILookup {
	func assoc(key: AnyObject, value: AnyObject) -> ITransientAssociative
}

protocol ITransientCollection {
	func conj(value: AnyObject) -> ITransientAssociative
	func persistent() -> IPersistentCollection
}

protocol ITransientMap : ITransientAssociative, ICounted {
	func assoc(key: AnyObject, value: AnyObject) -> ITransientMap
	func without(key: AnyObject) -> ITransientMap
	func persistent() -> IPersistentMap
}

protocol ITransientVector : ITransientAssociative, IIndexed {
	func assocN(index: Int, value: AnyObject) -> ITransientVector
	func pop() -> ITransientVector
}

protocol ITransientSet : ITransientCollection, ICounted {
	func disjoin() -> ITransientSet
	func containsObject(value: AnyObject) -> Bool
	subscript(i: AnyObject) -> AnyObject? { get }
}
