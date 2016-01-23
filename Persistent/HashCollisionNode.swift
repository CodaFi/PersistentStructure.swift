//
//  HashCollisionNode.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class HashCollisionNode : INode {
	private var _hash: Int
	private var _count: Int
	private var _array: Array<AnyObject>
	private var _edit: NSThread?

	init(edit: NSThread?, hash: Int, count: Int, array: Array<AnyObject>) {
		_edit = edit
		_hash = hash
		_count = count
		_array = array
	}

	func assocWithShift(shift: Int, hash: Int, key: AnyObject, value val: AnyObject, addedLeaf: AnyObject?) -> INode? {
		if hash == _hash {
			let idx: Int = self.findIndex(key)
			if idx != NSNotFound {
				if _array[idx + 1] === val {
					return self
				}
				return HashCollisionNode(edit: nil, hash: _hash, count: _count, array: Utils.cloneAndSetObject(_array, index: idx + 1, node: val))
			}
			var newArray: Array<AnyObject> = []
			newArray.reserveCapacity(2 * (_count + 1))
			ArrayCopy(_array, 0, newArray, 0, UInt(2 * _count))
			newArray[2 * _count] = key
			newArray[2 * _count + 1] = val
//			addedLeaf.val = addedLeaf
			return HashCollisionNode(edit: _edit, hash: hash, count: _count + 1, array: newArray)
		}
		return BitmapIndexedNode(onThread: nil, bitmap: Utils.bitPos(_hash, shift: shift), array: [ NSNull(), self ])
	}

	func withoutWithShift(shift: Int, hash: Int, key: AnyObject) -> INode? {
		let idx: Int = self.findIndex(key)
		if idx == NSNotFound {
			return self
		}
		if _count == 1 {
			return nil
		}
		return HashCollisionNode(edit: nil, hash: hash, count: _count - 1, array: Utils.removePair(_array, index: idx / 2))
	}

	func findWithShift(shift: Int, hash: Int, key: AnyObject) -> IMapEntry? {
		let idx: Int = self.findIndex(key)
		if idx < 0 {
			return nil
		}
		if Utils.equiv(key, other: _array[idx]) {
			return MapEntry(key: _array[idx], val: _array[idx + 1])
		}
		return nil
	}

	func findWithShift(shift: Int, hash: Int, key: AnyObject, notFound: AnyObject) -> AnyObject? {
		let idx: Int = self.findIndex(key)
		if idx < 0 {
			return notFound
		}
		if Utils.equiv(key, other: _array[idx]) {
			return _array[idx + 1]
		}
		return notFound
	}

	func nodeSeq() -> ISeq {
		return NodeSeq(array: _array)
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial: AnyObject) -> AnyObject {
		return NodeSeq.kvreducearray(_array, reducer: f, initial: initial)
	}

	func findIndex(key: AnyObject) -> Int {
		for i in 0.stride(to: 2 * _count, by: 2) {
			if Utils.equiv(key, other: _array[i]) {
				return i
			}
		}
		return NSNotFound
	}

	func ensureEditable(edit: NSThread) -> HashCollisionNode {
		if _edit == edit {
			return self
		}
		var newArray: Array<AnyObject> = []
		newArray.reserveCapacity(2 * (_count + 1))
		ArrayCopy(_array, 0, newArray, 0, UInt(2 * _count))
		return HashCollisionNode(edit: edit, hash: _hash, count: _count, array: newArray)
	}

	func ensureEditable(edit: NSThread, count: Int, array: Array<AnyObject>) -> HashCollisionNode {
		if _edit == edit {
			_array = array
			_count = count
			return self
		}
		return HashCollisionNode(edit: edit, hash: _hash, count: count, array: array)
	}

	func editAndSetOnThread(edit: NSThread, index i: Int, withObject a: AnyObject) -> HashCollisionNode {
		let editable: HashCollisionNode = self.ensureEditable(edit)
		editable._array[i] = a
		return editable
	}

	func editAndSetOnThread(edit: NSThread, index i: Int, withObject a: AnyObject, index j: Int, withObject b: AnyObject) -> HashCollisionNode {
		let editable: HashCollisionNode = self.ensureEditable(edit)
		editable._array[i] = a
		editable._array[j] = b
		return editable
	}

	func assocOnThread(edit: NSThread?, shift: Int, hash: Int, key: AnyObject, val: AnyObject, addedLeaf: AnyObject?) -> INode? {
		if hash == _hash {
			let idx: Int = self.findIndex(key)
			if idx != NSNotFound {
				if _array[idx + 1] === val {
					return self
				}
				return self.editAndSetOnThread(edit!, index: idx + 1, withObject: val)
			}
			if _array.count > 2 * _count {
//				addedLeaf.val = addedLeaf
				let editable: HashCollisionNode = self.editAndSetOnThread(edit!, index: 2 * _count, withObject: key, index: 2 * _count, withObject: val)
				editable._count = _count.successor()
				return editable
			}
			var newArray: Array<AnyObject> = []
			newArray.reserveCapacity(_array.count + 2)
			ArrayCopy(_array, 0, newArray, 0, UInt(_array.count))
			newArray[_array.count] = key
			newArray[_array.count + 1] = val
//			addedLeaf.val = addedLeaf
			return self.ensureEditable(edit!, count: _count + 1, array: newArray)
		}
		return nil
	}

	func withoutOnThread(edit: NSThread?, shift: Int, hash: Int, key: AnyObject, addedLeaf removedLeaf: AnyObject?) -> INode? {
		let idx: Int = self.findIndex(key)
		if idx == NSNotFound {
			return self
		}
//		removedLeaf.val = removedLeaf
		if _count == 1 {
			return nil
		}
		let editable: HashCollisionNode = self.ensureEditable(edit!)
		editable._array[idx] = editable._array[2 * _count - 2]
		editable._array[idx + 1] = editable._array[2 * _count - 1]

		editable._array.removeAtIndex(2 * _count - 2)
		editable._array.removeAtIndex(2 * _count - 1)
		editable._count--
		return editable
	}
}