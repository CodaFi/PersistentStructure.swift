//
//  TransientVector.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public final class TransientVector : ITransientVector, ICounted {
	private var _count: Int
	private var _shift: Int
	private var _root: Node
	private var _tail: Array<AnyObject>

	public convenience init() {
		self.init(PersistentVector.empty)
	}
	
	public init(_ v: PersistentVector) {
		_count = Int(v.count)
		_shift = v.shift
		_root = TransientVector.editableRoot(v.root)
		_tail = TransientVector.editableTail(v.tail)
	}

	init(cnt: Int, shift: Int, node root: Node, tail: Array<AnyObject>) {
		_count = cnt
		_shift = shift
		_root = root
		_tail = tail
	}

	public var count : Int {
		self.ensureEditable()
		return _count
	}

	func ensureEditableNode(node: Node) -> Node {
		if node.edit === _root.edit {
			return node
		}
		return Node(edit: _root.edit, array: _root.array)
	}

	func ensureEditable() {
		let owner: NSThread? = _root.edit
		if owner == NSThread.currentThread() {
			return
		}
		if owner != nil {
			fatalError("Transient used by non-owner thread")
		}
		fatalError("Transient used after request to be made persistent")
	}

	class func editableRoot(node: Node) -> Node {
		return Node(edit: NSThread.currentThread(), array: node.array)
	}

	public func persistent() -> IPersistentCollection {
		self.ensureEditable()
		if _root.edit != nil && _root.edit != NSThread.currentThread() {
			fatalError("Mutation release by non-owner thread")
		}
		var trimmedTail: Array<AnyObject> = []
		trimmedTail.reserveCapacity(_count - self.tailoff)
		ArrayCopy(_tail, 0, trimmedTail, 0, UInt(trimmedTail.count))
		return PersistentVector(cnt: _count, shift: _shift, root: _root as! INode, tail: trimmedTail)
	}

	class func editableTail(tl: Array<AnyObject>) -> Array<AnyObject> {
		var ret: Array<AnyObject> = []
		ret.reserveCapacity(32)
		ArrayCopy(tl, 0, ret, 0, UInt(tl.count))
		return ret
	}

	public func conj(val: AnyObject) -> ITransientCollection {
		self.ensureEditable()
		let i: Int = _count
		if i - self.tailoff < 32 {
			_tail[i & 0x01f] = val
			_count = _count.successor()
			return self
		}
		var newroot : Node
		let tailnode: Node = Node(edit: _root.edit, array: _tail)
		_tail = []
		_tail.reserveCapacity(32)
		_tail[0] = val
		var newshift: Int = _shift
		if (_count >> 5) > (1 << _shift) {
			newroot = Node(edit: _root.edit)
			newroot.array[0] = _root
			newroot.array[1] = TransientVector.newPath(_root.edit!, level: _shift, node: tailnode)
			newshift += 5
		} else {
			newroot = self.pushTailAtLevel(_shift, parent: _root, tail: tailnode)
		}
		_root = newroot
		_shift = newshift
		_count = _count.successor()
		return self
	}

	func pushTailAtLevel(level: Int, parent ep: Node, tail tailnode: Node) -> Node {
		let parent = self.ensureEditableNode(ep)
		let subidx: Int = ((_count - 1) >> level) & 0x01f
		let ret: Node = parent
		
		var nodeToInsert: Node
		if level == 5 {
			nodeToInsert = tailnode
		} else if let child = parent.array[subidx] as? Node {
			nodeToInsert = self.pushTailAtLevel(level - 5, parent: child, tail: tailnode)
		} else {
			nodeToInsert = TransientVector.newPath(_root.edit!, level: level - 5, node: tailnode)
		}
		
		ret.array[subidx] = nodeToInsert
		return ret
	}

	class func newPath(edit: NSThread, level: Int, node: Node) -> Node {
		if level == 0 {
			return node
		}
		let ret: Node = Node(edit: edit)
		ret.array[0] = TransientVector.newPath(edit, level: level - 5, node: node)
		return ret
	}

	var tailoff : Int {
		if _count < 32 {
			return 0
		}
		return ((_count - 1) >> 5) << 5
	}

	func arrayFor(i: Int) -> Array<AnyObject> {
		if i >= 0 && i < _count {
			if i >= self.tailoff {
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

	func editableArrayFor(i: Int) -> Array<AnyObject> {
		if i >= 0 && i < _count {
			if i >= self.tailoff {
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

	public func objectForKey(key: AnyObject) -> AnyObject? {
		self.ensureEditable()
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < _count {
				return self.objectAtIndex(i)!
			}
		}
		return nil
	}

	public func objectForKey(key: AnyObject, def notFound: AnyObject) -> AnyObject {
		self.ensureEditable()
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			if i >= 0 && i < _count {
				return self.objectAtIndex(i)!
			}
		}
		return notFound
	}

	public func objectAtIndex(i: Int) -> AnyObject? {
		self.ensureEditable()
		var node: Array<AnyObject> = self.arrayFor(i)
		return node[i & 0x01f]
	}

	public func objectAtIndex(i: Int, def notFound: AnyObject) -> AnyObject {
		if i >= 0 && i < Int(self.count) {
			return self.objectAtIndex(i)!
		}
		return notFound
	}

	public func assocN(i: Int, value val: AnyObject) -> ITransientVector {
		self.ensureEditable()
		if i >= 0 && i < _count {
			if i >= self.tailoff {
				_tail[i & 0x01f] = val
				return self
			}
			_root = self.doAssocAtLevel(_shift, node: _root, index: i, value: val)
			return self
		}
		if i == _count {
			return self.conj(val) as! ITransientVector
		}
		fatalError("Range or index out of bounds")
	}

	public func associateKey(key: AnyObject, value val: AnyObject) -> ITransientMap {
		if Utils.isInteger(key) {
			let i: Int = (key as! NSNumber).integerValue
			return self.assocN(i, value: val) as! ITransientMap
		}
		fatalError("Key must be an integer")
	}

	func doAssocAtLevel(level: Int, node ne: Node, index i: Int, value val: AnyObject) -> Node {
		let node = self.ensureEditableNode(ne)
		let ret: Node = node
		if level == 0 {
			ret.array[i & 0x01f] = val
		} else {
			let subidx: Int = (i >> level) & 0x01f
			ret.array[subidx] = self.doAssocAtLevel(level - 5, node: node.array[subidx] as! Node, index: i, value: val)
		}
		return ret
	}

	public var pop : ITransientVector {
		self.ensureEditable()
		if _count == 0 {
			fatalError("Can't pop from an empty vector")
		}
		if _count == 1 {
			_count = 0
			return self
		}
		let i: Int = _count - 1
		if (i & 0x01f) > 0 {
			_count--
			return self
		}
		let newtail: Array = self.editableArrayFor(_count - 2)
		var newroot: Node = self.popTailAtLevel(_shift, node: _root) ?? Node(edit: _root.edit)
		var newshift: Int = _shift
		if _shift > 5 /*&& newroot!.array[1] == nil*/ {
			newroot = self.ensureEditableNode(newroot.array[0] as! Node)
			newshift -= 5
		}
		_root = newroot
		_shift = newshift
		_count--
		_tail = newtail
		return self
	}

	func popTailAtLevel(level: Int, node ne: Node) -> Node? {
		let node = self.ensureEditableNode(ne)
		let subidx: Int = ((_count - 2) >> level) & 0x01f
		if level > 5 {
			let newchild: Node? = self.popTailAtLevel(level - 5, node: node.array[subidx] as! Node)
			if newchild == nil && subidx == 0 {
				return nil
			} else {
				let ret: Node = node
				ret.array[subidx] = newchild!
				return ret
			}
		} else if subidx == 0 {
			return nil
		} else {
			let ret: Node = node
			ret.array.removeAtIndex(subidx)
			return ret
		}
	}
}
