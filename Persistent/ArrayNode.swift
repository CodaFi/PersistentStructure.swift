//
//  ArrayNode.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class ArrayNode : INode {
	private var _count: Int
	private var _array: Array<AnyObject>
	private let _edit: NSThread?

	init() {
		_count = 0
		_array = []
		_edit = nil
	}

	init(onThread edit: NSThread?, count: Int, array: Array<AnyObject>) {
		_edit = edit
		_count = count
		_array = array
	}

	func assocWithShift(shift: Int, hash: Int, key: AnyObject, value val: AnyObject) -> INode? {
		let idx: Int = Utils.mask(hash, shift: shift)
		guard let node = _array[idx] as? INode else {
			return ArrayNode(onThread: nil, count: _count + 1, array: Utils.cloneAndSetNode(_array, index: idx, node: BitmapIndexedNode.empty.assocWithShift(shift + 5, hash: hash, key: key, value: val)))
		}
		let n: INode? = node.assocWithShift(shift + 5, hash: hash, key: key, value: val)
		if n === node {
			return self
		}
		return ArrayNode(onThread: nil, count: _count, array: Utils.cloneAndSetNode(_array, index: idx, node: n))
	}

	func withoutWithShift(shift: Int, hash: Int, key: AnyObject) -> INode? {
		let idx: Int = Utils.mask(hash, shift: shift)
		guard let node = _array[idx] as? INode else {
			return self
		}
		
		let n: INode? = node.withoutWithShift(shift + 5, hash: hash, key: key)
		if n === node {
			return self
		}
		if n == nil {
			if _count <= 8 {
				return self.packOnThread(nil, index: idx)
			}
			return ArrayNode(onThread: nil, count: _count - 1, array: Utils.cloneAndSetNode(_array, index: idx, node: n))
		} else {
			return ArrayNode(onThread: nil, count: _count, array: Utils.cloneAndSetNode(_array, index: idx, node: n))
		}
	}

	func findWithShift(shift: Int, hash: Int, key: AnyObject) -> IMapEntry? {
		let idx: Int = Utils.mask(hash, shift: shift)
		guard let node = _array[idx] as? INode else {
			return nil
		}
		return node.findWithShift(shift + 5, hash: hash, key: key)
	}

	func findWithShift(shift: Int, hash: Int, key: AnyObject, notFound: AnyObject) -> AnyObject? {
		let idx: Int = Utils.mask(hash, shift: shift)
		guard let node = _array[idx] as? INode else {
			return nil
		}
		return node.findWithShift(shift + 5, hash: hash, key: key, notFound: notFound)
	}

	var nodeSeq : ISeq {
		return Seq(nodes: _array)
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial ini: AnyObject) -> AnyObject {
		var initial = ini
		for i in (0..<_array.count) {
			if let node = _array[i] as? INode {
				initial = node.kvreduce(f, initial: initial)
				if Utils.isReduced(initial) {
					return (initial as! IDeref).deref
				}
			}
		}
		return initial
	}

	func ensureEditable(edit: NSThread) -> ArrayNode {
		if _edit == edit {
			return self
		}
		return ArrayNode(onThread: edit, count: _count, array: _array)
	}

	func editAndSetOnThread(edit: NSThread, index i: Int, node n: INode?) -> ArrayNode {
		let editable: ArrayNode = self.ensureEditable(edit)
		editable._array[i] = n!
		return editable
	}

	func packOnThread(edit: NSThread?, index idx: Int) -> INode? {
		var newArray: Array<AnyObject> = []
		newArray.reserveCapacity(2 * (_count - 1))
		var j: Int = 1
		var bitmap: Int = 0
		for i in (0..<idx) {
			if _array.count > i {
				newArray[j] = _array[i]
				bitmap |= 1 << i
				j += 2
			}
		}
		for i in ((idx + 1)..<_array.count) {
			if _array.count > i {
				newArray[j] = _array[i]
				bitmap |= 1 << i
				j += 2
			}
		}
		return BitmapIndexedNode(onThread: edit, bitmap: bitmap, array: newArray)
	}

	func assocOnThread(edit : NSThread?, shift : Int, hash : Int, key : AnyObject, val : AnyObject) -> INode? {
		let idx: Int = Utils.mask(hash, shift: shift)
		guard let node = _array[idx] as? INode else {
			let editable: ArrayNode = self.editAndSetOnThread(edit!, index: idx, node: BitmapIndexedNode.empty.assocOnThread(edit, shift: shift + 5, hash: hash, key: key, val: val))
			editable._count = _count.successor()
			return editable
		}
		let n: INode? = node.assocOnThread(edit, shift: shift + 5, hash: hash, key: key, val: val)
		if n === node {
			return self
		}
		return self.editAndSetOnThread(edit!, index: idx, node: n)
	}

	func withoutOnThread(edit : NSThread?, shift : Int, hash : Int, key : AnyObject) -> INode? {
		let idx: Int = Utils.mask(hash, shift: shift)
		guard let node = _array[idx] as? INode else {
			return self
		}
		let n: INode? = node.withoutOnThread(edit, shift: shift + 5, hash: hash, key: key)
		if n === node {
			return self
		}
		if n == nil {
			if _count <= 8 {
				return self.packOnThread(edit, index: idx)
			}
			let editable: ArrayNode = self.editAndSetOnThread(edit!, index: idx, node: n)
			editable._count--
			return editable
		}
		return self.editAndSetOnThread(edit!, index: idx, node: n)
	}
}
