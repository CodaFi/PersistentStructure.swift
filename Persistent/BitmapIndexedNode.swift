//
//  BitmapIndexedNode.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var EMPTY: BitmapIndexedNode = BitmapIndexedNode.createOnThread(nil, bitmap: 0, array: [])

class BitmapIndexedNode: NSObject, INode {
	var _array: Array<AnyObject>

	private var _bitmap: Int
	private var _edit: NSThread?

	override init() {
		_array = []
		_bitmap = 0
		_edit = nil
		super.init()
	}

	class func empty() -> BitmapIndexedNode {
		return EMPTY
	}

	func index(bit: Int) -> Int {
		return Utils.bitCount(UInt(_bitmap & (bit - 1)))
	}

	class func createOnThread(edit: NSThread?, bitmap: Int, array: Array<AnyObject>) -> BitmapIndexedNode {
		let node: BitmapIndexedNode = BitmapIndexedNode()
		node._bitmap = bitmap
		node._array = array
		node._edit = edit
		return node
	}

	func assocWithShift(shift: Int, hash: Int, key: AnyObject, value val: AnyObject, addedLeaf: Box) -> INode? {
		let bit: Int = Utils.bitPos(hash, shift: shift)
		let idx: Int = self.index(bit)
		if (_bitmap & bit) != 0 {
			let keyOrNull: AnyObject? = _array[2 * idx]
			let valOrNode: AnyObject? = _array[2 * idx + 1]
			if keyOrNull == nil {
				let n: INode? = (valOrNode as? INode)!.assocWithShift(shift + 5, hash: hash, key: key, value: val, addedLeaf: addedLeaf)
				if n === valOrNode {
					return self
				}
				return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap, array: Utils.cloneAndSetObject(_array, index: 2 * idx + 1, node: n!))
			}
			if Utils.equiv(key, other: (keyOrNull)) {
				if val === valOrNode {
					return self
				}
				return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap, array: Utils.cloneAndSetObject(_array, index: 2 * idx + 1, node: val))
			}
			addedLeaf.val = addedLeaf
			return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap, array: Utils.cloneAndSet(_array, index: 2 * idx, withObject: NSNull(), index: 2 * idx + 1, withObject: Utils.createNodeWithShift(shift + 5, key: keyOrNull!, value: valOrNode!, hash: hash, key: key, value: val)!))
		} else {
			let n: Int = Utils.bitCount(UInt(_bitmap))
			if n >= 16 {
				var nodes: Array<AnyObject> = []
				nodes.reserveCapacity(32)
				let jdx: Int = Utils.mask(hash, shift: shift)
				nodes[jdx] = EMPTY.assocWithShift(shift + 5, hash: hash, key: key, value: val, addedLeaf: addedLeaf)!
				var j: Int = 0
				for var i = 0; i < 32; i++ {
					if ((_bitmap >> i) & 1) != 0 {
						if _array.count <= j {
							nodes[i] = _array[j + 1] as! INode
						} else {
							nodes[i] = EMPTY.assocWithShift(shift + 5, hash: Int(Utils.hash(_array[j])), key: _array[j], value: _array[j + 1], addedLeaf: addedLeaf)!
						}
						j += 2
					}
				}
				return ArrayNode.createOnThread(nil, count: n + 1, array: nodes)
			} else {
				var newArray: Array<AnyObject> = []
				newArray.reserveCapacity(2 * (n + 1))
				ArrayCopy(_array, 0, newArray, 0, UInt(2 * idx))
				newArray[2 * idx] = key
				addedLeaf.val = addedLeaf
				newArray[2 * idx + 1] = val
				ArrayCopy(_array, UInt(2 * idx), newArray, UInt(2 * (idx + 1)), UInt(2 * (n - idx)))
				return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap | bit, array: newArray)
			}
		}
	}

	func withoutWithShift(shift: Int, hash: Int, key: AnyObject) -> INode? {
		let bit: Int = Utils.bitPos(hash, shift: shift)
		if (_bitmap & bit) == 0 {
			return self
		}
		let idx: Int = self.index(bit)
		let keyOrNull: AnyObject? = _array[2 * idx]
		let valOrNode: AnyObject? = _array[2 * idx + 1]
		if keyOrNull == nil {
			let n: INode? = (valOrNode as! INode).withoutWithShift(shift + 5, hash: hash, key: key)
			if n === valOrNode {
				return self
			}
			if n != nil {
				return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap, array: Utils.cloneAndSetNode(_array, index: 2 * idx + 1, node: n))
			}
			if _bitmap == bit {
				return nil
			}
			return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap ^ bit, array: Utils.removePair(_array, index: idx))
		}
		if Utils.equiv(key, other: (keyOrNull)) {
			return BitmapIndexedNode.createOnThread(nil, bitmap: _bitmap ^ _bitmap, array: Utils.removePair(_array, index: idx))
		}
		return self
	}

	func findWithShift(shift: Int, hash: Int, key: AnyObject) -> IMapEntry? {
		let bit: Int = Utils.bitPos(hash, shift: shift)
		if (_bitmap & bit) == 0 {
			return nil
		}
		let idx: Int = self.index(bit)
		let keyOrNull: AnyObject? = _array[2 * idx]
		let valOrNode: AnyObject? = _array[2 * idx + 1]
		if keyOrNull == nil {
			return (valOrNode as! INode).findWithShift(shift + 5, hash: hash, key: key)
		}
		if Utils.equiv(key, other: (keyOrNull)!) {
			return MapEntry(key: keyOrNull!, val: valOrNode!)
		}
		return nil
	}

	func findWithShift(shift : Int, hash : Int, key : AnyObject, notFound : AnyObject) -> AnyObject? {
		let bit: Int = Utils.bitPos(hash, shift: shift)
		if (_bitmap & bit) == 0 {
			return notFound
		}
		let idx: Int = self.index(bit)
		let keyOrNull: AnyObject? = _array[2 * idx]
		let valOrNode: AnyObject? = _array[2 * idx + 1]
		if keyOrNull == nil {
			return (valOrNode as! INode).findWithShift(shift + 5, hash: hash, key: key, notFound: notFound)
		}
		if Utils.equiv(key, other: keyOrNull!) {
			return valOrNode!
		}
		return notFound
	}

	func nodeSeq() -> ISeq? {
		return NodeSeq(array: _array)
	}

	func kvreduce(f: (AnyObject?, AnyObject?, AnyObject?) -> AnyObject, initial: AnyObject) -> AnyObject {
		return NodeSeq.kvreducearray(_array, reducer: f, initial: initial)
	}

	func ensureEditable(thread: NSThread) -> AnyObject {
		if _edit != thread {
			return self
		}
		let n: Int = Utils.bitCount(UInt(_bitmap))
		var newArray: Array<AnyObject> = []
		newArray.reserveCapacity(n >= 0 ? 2 * (n + 1) : 4)
		ArrayCopy(_array, 0, newArray, 0, UInt(2 * n))
		return BitmapIndexedNode.createOnThread(_edit, bitmap: _bitmap, array: newArray)
	}

	func editAndSet(edit: NSThread, index i: Int, object a: AnyObject) -> BitmapIndexedNode {
		let editable: BitmapIndexedNode = self.ensureEditable(edit) as! BitmapIndexedNode
		editable._array[i] = a
		return editable
	}

	func editAndSet(edit: NSThread, index i: Int, withObject a: AnyObject?, index j: Int, withObject b: AnyObject) -> BitmapIndexedNode {
		let editable: BitmapIndexedNode = self.ensureEditable(edit) as! BitmapIndexedNode
		editable._array[i] = a!
		editable._array[j] = b
		return editable
	}

	func editAndRemovePair(edit: NSThread, bit: Int, index i: Int) -> BitmapIndexedNode? {
		if _bitmap == bit {
			return nil
		}
		let editable: BitmapIndexedNode = self.ensureEditable(edit) as! BitmapIndexedNode
		editable._bitmap ^= bit
		ArrayCopy(editable._array, UInt(2 * (i + 1)), editable._array, UInt(2 * i), UInt(editable._array.count - 2 * (i + 1)))
		editable._array.removeAtIndex(editable._array.count - 2)
		editable._array.removeAtIndex(editable._array.count - 1)
		return editable
	}

	func assocOnThread(edit: NSThread?, shift: Int, hash: Int, key: AnyObject, val: AnyObject, addedLeaf: Box) -> INode? {
		let bit: Int = Utils.bitPos(hash, shift: shift)
		let idx: Int = self.index(bit)
		if (_bitmap & bit) != 0 {
			let keyOrNull: AnyObject? = _array[2 * idx]
			let valOrNode: AnyObject? = _array[2 * idx + 1]
			if keyOrNull == nil {
				let n: INode? = (valOrNode as? INode)!.assocOnThread(edit, shift: shift + 5, hash: hash, key: key, val: val, addedLeaf: addedLeaf)
				if n === valOrNode {
					return self
				}
				return self.editAndSet(edit!, index: 2 * idx + 1, object: n!)
			}
			if Utils.equiv(key, other: (keyOrNull)!) {
				if val === valOrNode {
					return self
				}
				return self.editAndSet(edit!, index: 2 * idx + 1, object: val)
			}
			addedLeaf.val = addedLeaf
			return self.editAndSet(edit!, index: 2 * idx, withObject: nil, index: 2 * idx + 1, withObject: Utils.createNodeOnThread(edit!, shift: shift + 5, key: keyOrNull!, value: valOrNode!, hash: hash, key: key, value: val)!)
		} else {
			let n: Int = Utils.bitCount(UInt(_bitmap))
			if n * 2 < _array.count {
				addedLeaf.val = addedLeaf
				let editable: BitmapIndexedNode = self.ensureEditable(edit!) as! BitmapIndexedNode
				ArrayCopy(editable._array, UInt(2 * idx), editable._array, UInt(2 * (idx + 1)), UInt(2 * (n - idx)))
				editable._array[2 * idx] = key
				editable._array[2 * idx + 1] = val
				editable._bitmap |= bit
				return editable
			}
			if n >= 16 {
				var nodes: Array<AnyObject> = []
				let jdx: Int = Utils.mask(hash, shift: shift)
				nodes[jdx] = EMPTY.assocOnThread(edit, shift: shift + 5, hash: hash, key: key, val: val, addedLeaf: addedLeaf)!
				var j: Int = 0
				for var i = 0; i < 32; i++ {
					if ((_bitmap >> i) & 1) != 0 {
						if _array.count <= j {
							nodes[i] = _array[j + 1] as! INode
						} else {
							nodes[i] = EMPTY.assocOnThread(edit, shift: shift + 5, hash: Int(Utils.hash(_array[j])), key: _array[j], val: _array[j + 1], addedLeaf: addedLeaf)!
						}
						j += 2
					}
				}
				return ArrayNode.createOnThread(edit, count: n + 1, array: nodes)
			} else {
				var newArray: Array<AnyObject> = []
				newArray.reserveCapacity(2 * (n + 4))
				ArrayCopy(_array, 0, newArray, 0, UInt(2 * idx))
				newArray[2 * idx] = key
				addedLeaf.val = addedLeaf
				newArray[2 * idx + 1] = val
				ArrayCopy(_array, UInt(2 * idx), newArray, UInt(2 * (idx + 1)), UInt(2 * (n - idx)))
				let editable: BitmapIndexedNode = self.ensureEditable(edit!) as! BitmapIndexedNode
				editable._array = newArray
				editable._bitmap |= bit
				return editable
			}
		}
	}

	func withoutOnThread(edit: NSThread?, shift: Int, hash: Int, key: AnyObject, addedLeaf removedLeaf: Box) -> INode? {
		let bit: Int = Utils.bitPos(hash, shift: shift)
		if (_bitmap & bit) == 0 {
			return self
		}
		let idx: Int = self.index(bit)
		let keyOrNull: AnyObject? = _array[2 * idx]
		let valOrNode: AnyObject? = _array[2 * idx + 1]
		if keyOrNull == nil {
			let n: INode? = (valOrNode as? INode)!.withoutOnThread(edit, shift: shift + 5, hash: hash, key: key, addedLeaf: removedLeaf)
			if n === valOrNode {
				return self
			}
			if n != nil {
				return self.editAndSet(edit!, index: 2 * idx + 1, object: n!)
			}
			if _bitmap == bit {
				return nil
			}
			return self.editAndRemovePair(edit!, bit: bit, index: idx)
		}
		if Utils.equiv(key, other: keyOrNull!) {
			removedLeaf.val = removedLeaf
			return self.editAndRemovePair(edit!, bit: bit, index: idx)
		}
		return self
	}
}