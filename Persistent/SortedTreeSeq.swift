//
//  SortedTreeSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 12/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class SortedTreeSeq: AbstractSeq, IObj {
	private var _stack: ISeq
	private var _asc: Bool
	private var _cnt: Int

	init(stack: ISeq, ascending asc: Bool) {
		_stack = stack
		_asc = asc
		_cnt = -1
		super.init()
	}

	init(stack: ISeq, ascending asc: Bool, count: Int) {
		_stack = stack
		_asc = asc
		_cnt = count
		super.init()
	}

	init(meta: IPersistentMap?, stack: ISeq, ascending asc: Bool, count: Int) {
		_stack = stack
		_asc = asc
		_cnt = count
		super.init(meta: meta)
	}

	class func createWithRoot(t: TreeNode?, ascending asc: Bool, count cnt: Int) -> SortedTreeSeq {
		return SortedTreeSeq(stack: SortedTreeSeq.pushNode(t, stack: EmptySeq(), ascending: asc), ascending: asc, count: cnt)
	}

	class func pushNode(var t: TreeNode?, var stack: ISeq, ascending asc: Bool) -> ISeq {
		while t != nil {
			stack = Utils.cons(t!, to: stack)
			t = asc ? t!.left() : t!.right()
		}
		return stack
	}

	override func first() -> AnyObject? {
		return _stack.first()
	}

	override func next() -> ISeq {
		let t = _stack.first() as! TreeNode
		let nextstack = SortedTreeSeq.pushNode(_asc ? t.right() : t.left(), stack: _stack.next(), ascending: _asc)
		return SortedTreeSeq(stack: nextstack, ascending: _asc, count: _cnt - 1)
	}

	override var count : Int {
		if _cnt < 0 {
			return super.count
		}
		return _cnt
	}

	func withMeta(meta: IPersistentMap?) -> IObj {
		return SortedTreeSeq(meta: meta, stack: _stack, ascending: _asc, count: _cnt)
	}
}
