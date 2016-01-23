//
//  ChunkedSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class ChunkedSeq: AbstractSeq, IChunkedSeq {
	private let _vec: PersistentVector
	private let _node: Array<AnyObject>
	private let _i: Int
	private let _offset: Int

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

	var chunkedFirst : IChunk? {
		return ArrayChunk(array: _node, offset: _offset)
	}

	var chunkedNext : ISeq {
		if (_i + _node.count) < _vec.count {
			return ChunkedSeq(vec: _vec, index: _node.count, offset: 0)
		}
		return EmptySeq()
	}

	var chunkedMore : ISeq {
		if self.chunkedNext.count != 0 {
			return self.chunkedNext
		}
		return PersistentList.empty
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		if meta === _meta {
			return self
		}
		return ChunkedSeq(meta: meta, vec: _vec, node: _node, index: _i, offset: _offset)
	}

	override var first : AnyObject {
		return _node[_offset]
	}

	override var next : ISeq {
		if _offset + 1 < _node.count {
			return ChunkedSeq(vec: _vec, node: _node, index: _i, offset: _offset + 1)
		}
		return self.chunkedNext
	}

	override var count : Int {
		return _vec.count - (_i + _offset)
	}
}
