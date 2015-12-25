//
//  NodeSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class NodeSeq: AbstractSeq {
	private var _array: Array<AnyObject>
	private var _startingIndex: Int
	private var _backingSeq: ISeq?

	convenience init(array: Array<AnyObject>) {
		self.init(array: array, index: 0, sequence: nil)
	}

	convenience init(array: Array<AnyObject>, index: Int) {
		self.init(meta: nil, array: array, index: index, sequence: nil)
	}

	convenience init(array: Array<AnyObject>, index: Int, sequence seq: ISeq?) {
		if seq != nil {
			self.init(meta: nil, array: array, index: index, sequence: seq)
			return
		}

		for var j = index; j < array.count; j += 2 {
//			if array[j] != nil {
//				self.init(meta: nil, array: array, index: j, sequence: nil)
//				return
//			}
			let node: INode? = array[j + 1] as? INode
			if node != nil {
				let nodeSeq: ISeq? = node?.nodeSeq()
				if nodeSeq != nil {
					self.init(meta: nil, array: array, index: j + 2, sequence: nodeSeq)
					return
				}
			}
		}
		fatalError("Cannot create NodeSeq from given sequence \(seq)")
	}

	init(meta: IPersistentMap?, array: Array<AnyObject>, index: Int, sequence seq: ISeq?) {
		_array = array
		_startingIndex = index
		_backingSeq = seq
		super.init(meta: meta)
	}

	func withMeta(meta : IPersistentMap) -> NodeSeq {
		return NodeSeq(meta: meta, array: _array, index: _startingIndex, sequence: _backingSeq)
	}

	class func kvreducearray(array: Array<AnyObject>, reducer f: (AnyObject, AnyObject, AnyObject) -> AnyObject, var initial: AnyObject) -> AnyObject {
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

	override func first() -> AnyObject? {
		if _backingSeq != nil {
			return _backingSeq?.first()
		}
		return MapEntry(key: _array[_startingIndex], val: _array[_startingIndex + 1])
	}

	override func next() -> ISeq {
		if let bs = _backingSeq {
			return NodeSeq(array: _array, index: _startingIndex, sequence: bs.next())
		}
		return NodeSeq(array: _array, index: _startingIndex + 2, sequence: nil)
	}
}
