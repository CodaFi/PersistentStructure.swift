//
//  Seq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/19/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class Seq : AbstractSeq {
	private var _nodes : Array<AnyObject>
	private var _i : Int
	private var _s : ISeq

	convenience init(nodes: Array<AnyObject>) {
		self.init(meta: nil, nodes: nodes, index: 0, seq: EmptySeq())
	}

	init(meta: IPersistentMap?, nodes: Array<AnyObject>, index i: Int, seq: ISeq) {
		_nodes = nodes
		_i = i
		_s = seq
		super.init(meta: meta)
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		return Seq(meta: meta, nodes: _nodes, index: _i, seq: _s)
	}

	override var first : AnyObject? {
		return _s.first
	}

	override var next : ISeq {
		return Seq(meta: nil, nodes: _nodes, index: _i, seq: _s.next)
	}
}
