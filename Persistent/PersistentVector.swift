//
//  PersistentVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var NOEDIT: NSThread? = nil
private let EMPTYNODE: Node = Node(edit: NOEDIT)
private let EMPTY: PersistentVector = PersistentVector(meta: nil, count: 0, shift: 5, node: EMPTYNODE, tail: [])

class PersistentVector: AbstractPersistentVector, IObj, IEditableCollection {
	private var _count: Int
	private var _shift: Int
	private var _root: Node
	private var _tail: Array<AnyObject>
	private var _meta: IPersistentMap?

	init(cnt: Int, shift: Int, root: INode, tail: Array<AnyObject>) {
		_meta = nil
		_count = cnt
		_shift = shift
		_root = root as! Node
		_tail = tail
	}

	init(meta: IPersistentMap?, count cnt: Int, shift: Int, node root: Node, tail: Array<AnyObject>) {
		_meta = meta
		_count = cnt
		_shift = shift
		_root = root
		_tail = tail
	}

	override func empty() -> IPersistentCollection {
		if let m = self.meta() {
			return EMPTY.withMeta(m) as! IPersistentCollection
		}
		return EMPTY
	}

	override func assocN(i: Int, value val: AnyObject) -> IPersistentVector {
		if i >= 0 && i < _count {
			if i >= self.tailoff() {
				var newTail: Array<AnyObject> = []
				newTail.reserveCapacity(_tail.count)
				ArrayCopy(_tail, 0, newTail, 0, UInt(_tail.count))
				newTail[i & 0x01f] = val
				return PersistentVector(meta: self.meta(), count: _count, shift: _shift, node: _root, tail: newTail)
			}
			return PersistentVector(meta: self.meta(), count: _count, shift: _shift, node: PersistentVector.doAssocAtLevel(_shift, node: _root, index: i, value: val), tail: _tail)
		}
		if i == _count {
			return self.cons(val)
		}
		fatalError("Range or index out of bounds")
	}

	func arrayFor(i: Int) -> Array<AnyObject> {
		if i >= 0 && i < _count {
			if i >= self.tailoff() {
				return _tail
			}
			var node: Node = _root
			for var level = _shift; level > 0; level -= 5 {
				node = node.array[(i >> level) & 0x01f] as! Node
			}
			return node.array
		}
		fatalError("Range or index out of bounds")
	}

	func shift() -> Int {
		return _shift
	}

	func root() -> Node {
		return _root
	}

	func tail() -> Array<AnyObject> {
		return _tail
	}

	class func createWithSeq(items: ISeq) -> PersistentVector {
		var ret: ITransientVector = EMPTY.asTransient() as! ITransientVector
		for entry in items.generate() {
			ret = ret.conj(entry) as! ITransientVector
		}
		return ret.persistent() as! PersistentVector
	}

	class func createWithList(liste: IList?) -> PersistentVector {
		guard let list = liste else {
			return EMPTY
		}
		
		var ret: TransientVector = EMPTY.asTransient() as! TransientVector
		for item: AnyObject in list.generate() {
			ret = ret.conj(item) as! TransientVector
		}
		return ret.persistent() as! PersistentVector
	}

	class func createWithItems(items: Array<AnyObject>) -> PersistentVector {
		var ret: TransientVector = EMPTY.asTransient() as! TransientVector
		for i in (0..<items.count) {
			ret = ret.conj(items[i]) as! TransientVector
		}
		return ret.persistent() as! PersistentVector
	}

	class func empty() -> PersistentVector {
		return EMPTY
	}

	class func emptyNode() -> Node {
		return EMPTYNODE
	}

	func asTransient() -> ITransientCollection {
		return TransientVector(v: self)
	}

	func tailoff() -> Int {
		if _count < 32 {
			return 0
		}
		return ((_count - 1) >> 5) << 5
	}

	override func objectAtIndex(i: Int) -> AnyObject {
		var node: Array<AnyObject> = self.arrayFor(i)
		return node[i & 0x01f]
	}

	func objectAtIndex(i: Int,  notFound: AnyObject) -> AnyObject {
		if i >= 0 && i < _count {
			return self.objectAtIndex(i)
		}
		return notFound
	}

	class func doAssocAtLevel(level: Int, node: Node, index i: Int, value val: AnyObject) -> Node {
		let ret: Node = Node(edit: node.edit, array: node.array)
		if level == 0 {
			ret.array[i & 0x01f] = val
		} else {
			let subidx: Int = (i >> level) & 0x01f
			ret.array[subidx] = PersistentVector.doAssocAtLevel(level - 5, node: node.array[subidx] as! Node, index: i, value: val)
		}
		return ret
	}

	override var count : Int {
		return _count
	}

	func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentVector(meta: meta, count: _count, shift: _shift, node: _root, tail: _tail)
	}

	func meta() -> IPersistentMap? {
		return _meta
	}

	override func cons(val: AnyObject) -> IPersistentVector {
		if _count - self.tailoff() < 32 {
			var newTail: Array<AnyObject> = []
			newTail.reserveCapacity(_tail.count + 1)
			ArrayCopy(_tail, 0, newTail, 0, UInt(_tail.count))
			newTail[_tail.count] = val
			return PersistentVector(meta: self.meta(), count: _count + 1, shift: _shift, node: _root, tail: newTail)
		}
		var newroot: Node
		let tailnode: Node = Node(edit: _root.edit, array: _tail)
		var newshift: Int = _shift
		if (_count >> 5) > (1 << _shift) {
			newroot = Node(edit: _root.edit)
			newroot.array[0] = _root
			newroot.array[1] = PersistentVector.newPath(_root.edit!, level: _shift, node: tailnode)
			newshift += 5
		} else {
			newroot = self.pushTailAtLevel(_shift, parent: _root, tail: tailnode)
		}
		return PersistentVector(meta: self.meta(), count: _count + 1, shift: newshift, node: newroot, tail: [ val ])
	}

	func pushTailAtLevel(level: Int, parent: Node, tail tailnode: Node) -> Node {
		let subidx: Int = ((_count - 1) >> level) & 0x01f
		let ret: Node = Node(edit: parent.edit, array: parent.array)
		
		var nodeToInsert: Node
		if level == 5 {
			nodeToInsert = tailnode
		} else if let child = parent.array[subidx] as? Node {
			nodeToInsert = self.pushTailAtLevel(level - 5, parent: child, tail: tailnode)
		} else {
			nodeToInsert = PersistentVector.newPath(_root.edit!, level: level - 5, node: tailnode)
		}
		
		ret.array[subidx] = nodeToInsert
		return ret
	}

	class func newPath(edit: NSThread, level: Int, node: Node) -> Node {
		if level == 0 {
			return node
		}
		let ret: Node = Node(edit: edit)
		ret.array[0] = PersistentVector.newPath(edit, level: level - 5, node: node)
		return ret
	}

	func chunkedSeq() -> IChunkedSeq {
		if self.count == 0 {
			return EmptySeq()
		}
		return ChunkedSeq(vec: self, index: 0, offset: 0)
	}

	override func seq() -> ISeq {
		return self.chunkedSeq()
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial ini: AnyObject) -> AnyObject {
		var initial = ini
		var step: Int = 0
		for i in 0.stride(to: _count, by: step) {
			var array: Array = self.arrayFor(i)
			for var j = 0; j < array.count; j = j.successor() {
				initial = f(initial, (j + i), array[j])
				if Utils.isReduced(initial) {
					return (initial as! IDeref).deref()
				}
			}
			step = array.count
		}
		return initial
	}

	override func pop() -> IPersistentStack {
		if _count == 0 {
			fatalError("Can't pop from an empty vector")
		}
		if _count == 1 {
			if let m = self.meta() {
				EMPTY.withMeta(m) as? IPersistentStack
			}
			return EMPTY
		}
		if _count - self.tailoff() > 1 {
			var newTail: Array<AnyObject> = []
			newTail.reserveCapacity(_tail.count - 1)
			ArrayCopy(_tail, 0, newTail, 0, UInt(newTail.count))
			return PersistentVector(meta: self.meta(), count: _count - 1, shift: _shift, node: _root, tail: newTail)
		}
		let newtail: Array = self.arrayFor(_count - 2)
		var newroot: Node = self.popTailAtLevel(_shift, node: _root) ?? EMPTYNODE
		var newshift: Int = _shift

		if _shift > 5 /*&& newroot!.array[1] == nil*/ {
			newroot = newroot.array[0] as! Node
			newshift -= 5
		}
		return PersistentVector(meta: self.meta(), count: _count - 1, shift: newshift, node: newroot, tail: newtail)
	}

	func popTailAtLevel(level: Int, node: Node) -> Node? {
		let subidx: Int = ((_count - 2) >> level) & 0x01f
		if level > 5 {
			let newchild: Node? = self.popTailAtLevel(level - 5, node: node.array[subidx] as! Node)
			if newchild == nil && subidx == 0 {
				return nil
			} else {
				let ret: Node = Node(edit: _root.edit, array: node.array)
				ret.array[subidx] = newchild!
				return ret
			}
		} else if subidx == 0 {
			return nil
		} else {
			let ret: Node = Node(edit: _root.edit, array: node.array)
			ret.array.removeAtIndex(subidx)
			return ret
		}
	}
}
