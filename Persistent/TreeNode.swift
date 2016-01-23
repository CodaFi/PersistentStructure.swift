//
//  TreeNode.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class TreeNode: MapEntry {
	private var _key: AnyObject

	init(k: AnyObject) {
		_key = k
		super.init()
	}

	func addLeft(ins: TreeNode) -> TreeNode? {
		return nil
	}

	func addRight(ins: TreeNode) -> TreeNode? {
		return nil
	}

	func removeLeft(del: TreeNode) -> TreeNode? {
		return nil
	}

	func removeRight(del: TreeNode) -> TreeNode? {
		return nil
	}

	var blacken : TreeNode? {
		return nil
	}

	var redden : TreeNode? {
		return nil
	}

	var left : TreeNode? {
		return nil
	}

	var right : TreeNode? {
		return nil
	}

	func replaceKey(key: AnyObject, byValue val: AnyObject, left: TreeNode, right: TreeNode) -> TreeNode? {
		return nil
	}

	override var key : AnyObject {
		return _key
	}

	override var val : AnyObject {
		fatalError("Subclass doesn't implement val!")
	}

	func balanceLeft(parent: TreeNode) -> TreeNode {
		return PersistentTreeMap.black(parent.key, val: parent.val, left: self, right: parent.right)
	}

	func balanceRight(parent: TreeNode) -> TreeNode {
		return PersistentTreeMap.black(parent.key, val: parent.val, left: parent.left, right: self)
	}
}

class BlackTreeNode: TreeNode {
	override func addLeft(ins: TreeNode) -> TreeNode {
		return ins.balanceLeft(self)
	}

	override func addRight(ins: TreeNode) -> TreeNode {
		return ins.balanceRight(self)
	}

	override func removeLeft(del: TreeNode) -> TreeNode? {
		return PersistentTreeMap.balanceLeftDel(_key, val: self.val, del: del, right: self.right!)
	}

	override func removeRight(del: TreeNode) -> TreeNode? {
		return PersistentTreeMap.balanceRightDel(_key, val: self.val, del: del, left: self.left!)
	}

	override var blacken : TreeNode {
		return self
	}

	override var redden : TreeNode {
		return RedTreeNode(k: _key)
	}

	override func replaceKey(key: AnyObject, byValue val: AnyObject, left: TreeNode, right: TreeNode) -> TreeNode {
		return PersistentTreeMap.black(key, val: val, left: left, right: right)
	}
}

class BlackTreeValue: BlackTreeNode {
	private var _val: AnyObject

	init(key: AnyObject, val: AnyObject) {
		_val = val
		super.init(k: key)
	}

	override var val : AnyObject {
		return _val
	}

	override var redden : TreeNode {
		return RedTreeValue(key: _key, val: _val)
	}
}

class BlackTreeBranch: BlackTreeNode {
	private var _left: TreeNode
	private var _right: TreeNode

	init(k: AnyObject, left: TreeNode, right: TreeNode) {
		_left = left
		_right = right
		super.init(k: k)
	}

	override var left : TreeNode {
		return _left
	}

	override var right : TreeNode {
		return _right
	}

	override var redden : TreeNode {
		return RedTreeBranch(k: _key, left: _left, right: _right)
	}
}

class BlackTreeBranchValue: BlackTreeBranch {
	private var _val: AnyObject

	init(key: AnyObject, val: AnyObject, left: TreeNode, right: TreeNode) {
		_val = val
		super.init(k: key, left: left, right: right)
	}

	override var val : AnyObject {
		return _val
	}

	override var redden : TreeNode {
		return RedTreeBranchValue(key: _key, val: _val, left: _left, right: _right)
	}
}

class RedTreeNode: TreeNode {

}

class RedTreeValue: RedTreeNode {
	private var _val: AnyObject

	init(key: AnyObject, val: AnyObject) {
		_val = val
		super.init(k: key)
	}

	override var val : AnyObject {
		return _val
	}

	override var blacken : TreeNode {
		return BlackTreeValue(key: _key, val: _val)
	}
}

class RedTreeBranch: RedTreeNode {
	private var _left: TreeNode
	private var _right: TreeNode

	init(k: AnyObject, left: TreeNode, right: TreeNode) {
		_left = left
		_right = right
		super.init(k: k)
	}

	override var left : TreeNode {
		return _left
	}

	override var right : TreeNode {
		return _right
	}

	override func balanceLeft(parent: TreeNode) -> TreeNode {
		if let ll = _left as? RedTreeNode {
			return PersistentTreeMap.red(_key, val: self.val, left: ll.blacken, right: PersistentTreeMap.black(parent.key, val: parent.val, left: _right, right: parent.right))
		} else if let rr = _right as? RedTreeNode {
			return PersistentTreeMap.red(rr.key, val: rr.val, left: rr.left!, right: PersistentTreeMap.black(parent.key, val: parent.val, left: rr.right, right: parent.right))
		} else {
			return super.balanceLeft(parent)
		}
	}

	override func balanceRight(parent: TreeNode) -> TreeNode {
		if let rr = _right as? RedTreeNode {
			return PersistentTreeMap.red(_key, val: self.val, left: PersistentTreeMap.black(parent.key, val: parent.val, left: parent.left, right: _left), right: rr.blacken)
		} else if let ll = _left as? RedTreeNode {
			return PersistentTreeMap.red(ll.key, val: ll.val, left: PersistentTreeMap.black(parent.key, val: parent.val, left: parent.left, right: ll.left), right: PersistentTreeMap.black(_key, val: self.val, left: ll.right, right: _right))
		} else {
			return super.balanceRight(parent)
		}
	}

	override var blacken : TreeNode {
		return BlackTreeBranch(k: _key, left: _left, right: _right)
	}
}

class RedTreeBranchValue: RedTreeBranch {
	private var _val: AnyObject

	init(key: AnyObject, val: AnyObject, left: TreeNode, right: TreeNode) {
		_val = val
		super.init(k: key, left: left, right: right)
	}

	override var val : AnyObject {
		return _val
	}

	override var blacken : TreeNode {
		return BlackTreeBranchValue(key: _key, val: _val, left: _left, right: _right)
	}
}

