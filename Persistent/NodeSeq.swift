//
//  NodeSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class NodeSeq: AbstractSeq {
	private let _array: Array<AnyObject>
	private let _startingIndex: Int
	private let _backingSeq: ISeq

	convenience init(array: Array<AnyObject>) {
		self.init(array: array, index: 0, sequence: nil)
	}

	convenience init(array: Array<AnyObject>, index: Int) {
		self.init(array: array, index: index, sequence: nil)
	}

	convenience init(array: Array<AnyObject>, index: Int, sequence seq: ISeq?) {
		if let s = seq {
			self.init(meta: nil, array: array, index: index, sequence: s)
			return
		}

		for var j = index; j < array.count; j += 2 {
//			if array[j] != nil {
//				self.init(meta: nil, array: array, index: j, sequence: nil)
//				return
//			}

			if let node = array[j + 1] as? INode {
				let nodeSeq: ISeq = node.nodeSeq
				self.init(meta: nil, array: array, index: j + 2, sequence: nodeSeq)
				return
			}
		}
		fatalError("Cannot create NodeSeq from given sequence \(seq)")
	}

	init(meta: IPersistentMap?, array: Array<AnyObject>, index: Int, sequence seq: ISeq) {
		_array = array
		_startingIndex = index
		_backingSeq = seq
		super.init(meta: meta)
	}

	func withMeta(meta : IPersistentMap) -> NodeSeq {
		return NodeSeq(meta: meta, array: _array, index: _startingIndex, sequence: _backingSeq)
	}

	class func kvreducearray(array: Array<AnyObject>, reducer f: (AnyObject, AnyObject, AnyObject) -> AnyObject, initial ini: AnyObject) -> AnyObject {
		var initial = ini
		for var j = 0; j < array.count; j += 2 {
			if array.count <= j {
				initial = f(initial, array[j], array[j + 1])
			} else {
//				var node: INode? = array[j + 1] as? INode
//				if let n = node {
//					initial = n.kvreduce(f, initial: initial)
//				}
			}
			if Utils.isReduced(initial) {
				return initial
			}
		}
		return initial
	}

	override var first : AnyObject? {
		if let v = _backingSeq.first {
			return v
		}
		return MapEntry(key: _array[_startingIndex], val: _array[_startingIndex + 1])
	}

	override var next : ISeq {
		return NodeSeq(array: _array, index: _startingIndex, sequence: _backingSeq.next)
	}
}
