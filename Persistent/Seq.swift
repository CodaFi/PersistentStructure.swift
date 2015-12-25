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
	private var _s : ISeq?

	class func create(nodes: Array<AnyObject>) -> ISeq? {
		return Seq.createWithMeta(nil, nodes: nodes, index: 0, seq: nil)
	}

	class func createWithMeta(meta: IPersistentMap?, nodes: Array<AnyObject>, index i: Int, seq s: ISeq?) -> ISeq? {
		if s != nil {
			return Seq.createWithMeta(meta, nodes: nodes, index: i, seq: s)
		}
		for var j = i; j < nodes.count; j++ {
			if let ins = nodes[j] as? INode {
				let ns: ISeq? = ins.nodeSeq()
				if ns != nil {
					return Seq.createWithMeta(meta, nodes: nodes, index: j + 1, seq: ns)
				}
			}
		}
		return nil
	}

	init(meta: IPersistentMap?, nodes: Array<AnyObject>, index i: Int, seq: ISeq?) {
		_nodes = nodes
		_i = i
		_s = seq
		super.init(meta: meta)
	}

	func withMeta(meta: IPersistentMap?) -> AnyObject {
		return Seq(meta: meta, nodes: _nodes, index: _i, seq: _s)
	}

	override func first() -> AnyObject? {
		return _s!.first()
	}

	override func next() -> ISeq? {
		return Seq.createWithMeta(nil, nodes: _nodes, index: _i, seq: _s!.next())
	}
}