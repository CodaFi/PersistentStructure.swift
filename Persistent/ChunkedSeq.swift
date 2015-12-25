//
//  ChunkedSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class ChunkedSeq: AbstractSeq, IChunkedSeq {
	private var _vec: PersistentVector
	private var _node: Array<AnyObject>
	private var _i: Int
	private var _offset: Int

	init(vec: PersistentVector, index i: Int, offset: Int) {
		_vec = vec
		_i = i
		_offset = offset
		_node = vec.arrayFor(i)
		super.init()
	}

	init(meta: IPersistentMap?, vec: PersistentVector, node: Array<AnyObject>, index i: Int, offset: Int) {
		_vec = vec
		_i = i
		_offset = offset
		_node = node
		super.init(meta: meta)
	}

	init(vec: PersistentVector, node: Array<AnyObject>, index i: Int, offset: Int) {
		_vec = vec
		_i = i
		_offset = offset
		_node = node
		super.init()
	}

	func chunkedFirst() -> IChunk? {
		return ArrayChunk(array: _node, offset: _offset)
	}

	func chunkedNext() -> ISeq? {
		if UInt(_i + _node.count) < _vec.count() {
			return ChunkedSeq(vec: _vec, index: _node.count, offset: 0)
		}
		return nil
	}

	func chunkedMore() -> ISeq? {
		let s: ISeq? = self.chunkedNext()
		if s == nil {
			return PersistentList.empty() as? ISeq
		}
		return s
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		if meta === _meta {
			return self
		}
		return ChunkedSeq(meta: meta, vec: _vec, node: _node, index: _i, offset: _offset)
	}

	override func first() -> AnyObject {
		return _node[_offset]
	}

	override func next() -> ISeq? {
		if _offset + 1 < _node.count {
			return ChunkedSeq(vec: _vec, node: _node, index: _i, offset: _offset + 1)
		}
		return self.chunkedNext()
	}

	override func count() -> UInt {
		return _vec.count() - UInt(_i + _offset)
	}
}
