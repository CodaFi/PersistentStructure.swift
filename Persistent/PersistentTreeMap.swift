//
//  PersistentTreeMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

private var EMPTY: PersistentTreeMap = PersistentTreeMap(meta: nil, comparator: { _ in .OrderedSame })

class PersistentTreeMap: AbstractPersistentMap, IObj, IReversible, ISorted {
	private var _comp: (AnyObject?, AnyObject?) -> NSComparisonResult
	private var _tree: TreeNode?
	private var _count: Int
	private var _meta: IPersistentMap?

	init(meta: IPersistentMap?, comparator comp: (AnyObject?, AnyObject?) -> NSComparisonResult) {
		_comp = comp
		_meta = meta
		_tree = nil
		_count = 0
		super.init()
	}

	init(meta: IPersistentMap?, comparator comp: (AnyObject?, AnyObject?) -> NSComparisonResult, tree: TreeNode?, count: Int) {
		_meta = meta
		_comp = comp
		_tree = tree
		_count = count
		super.init()
	}

	init(comp: (AnyObject?, AnyObject?) -> NSComparisonResult, tree: TreeNode?, count: Int, meta: IPersistentMap?) {
		_meta = meta
		_comp = comp
		_tree = tree
		_count = count
		super.init()
	}

	class func empty() -> IPersistentCollection? {
		return EMPTY
	}

	class func create(other: IMap?) -> IPersistentMap? {
		var ret: IPersistentMap? = EMPTY as IPersistentMap?
		for o: AnyObject in other!.allEntries()!.generate() {
			let e: MapEntry = o as! MapEntry
			ret = ret!.associateKey(e.key()!, withValue: e.val()!) as? IPersistentMap
		}
		return ret
	}

	class func empty() -> PersistentTreeMap {
		return EMPTY
	}

	func withMeta(meta: IPersistentMap?) -> IObj? {
		return PersistentTreeMap(meta: meta, comparator: _comp, tree: _tree, count: _count)
	}

	convenience init(comparator: (AnyObject?, AnyObject?) -> NSComparisonResult) {
		self.init(meta: nil, comparator: comparator)
	}

	class func createWithSeq(var items: ISeq?) -> AnyObject {
		var ret: IPersistentMap? = EMPTY
		for ; items != nil; items = items!.next().next() {
			if items?.next() == nil {
				fatalError("No value supplied for key: \(items!.first)")
			}
			ret = ret!.associateKey(items!.first()!, withValue: Utils.second(items!)!) as! PersistentTreeMap
		}
		return ret as! PersistentTreeMap
	}

	class func createWithComparator(comp: (AnyObject?, AnyObject?) -> NSComparisonResult, var seq items: ISeq?) -> AnyObject {
		var ret: IPersistentMap? = PersistentTreeMap(comparator: comp)
		for ; items != nil; items = items!.next().next() {
			if items!.next().count() == 0 {
				fatalError("No value supplied for key: \(items!.first)")
			}
			ret = ret!.associateKey(items!.first()!, withValue: Utils.second(items!)!) as! PersistentTreeMap
		}
		return ret as! PersistentTreeMap
	}

	override func containsKey(key: AnyObject) -> Bool {
		return self.objectForKey(key) != nil
	}

	func assocEx(key: AnyObject, value val: AnyObject) -> IPersistentMap? {
		let found: Box = Box(withVal: nil)
		let t: TreeNode? = self.add(_tree, key: key, val: val, found: found)
		if t == nil {
			fatalError("Key already present")
		}
		return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: t?.blacken(), count: _count + 1)
	}

	func associateKey(key: AnyObject, value val: AnyObject) -> IPersistentMap? {
		let found: Box = Box(withVal: nil)
		let t: TreeNode? = self.add(_tree, key: key, val: val, found: found)
		if t == nil {
			let foundNode: TreeNode = found.val as! TreeNode
			if foundNode.val() === val {
				return self
			}
			return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: self.replace(_tree!, key: key, val: val), count: _count + 1)
		}
		return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: t?.blacken(), count: _count + 1)
	}

	override func without(key: AnyObject) -> IPersistentMap? {
		let found: Box = Box(withVal: nil)
		let t: TreeNode? = self.remove(_tree, key: key, found: found)
		if t == nil {
			if found.val == nil {
				return self
			}
			return PersistentTreeMap(meta: self.meta(), comparator: _comp)
		}
		return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: t?.blacken(), count: _count - 1)
	}

	override func seq() -> ISeq {
		if _count > 0 {
			return SortedTreeSeq.createWithRoot(_tree, ascending: true, count: _count)
		}
		return EmptySeq()
	}

	func reversedSeq() -> ISeq {
		if _count > 0 {
			return SortedTreeSeq.createWithRoot(_tree, ascending: false, count: _count)
		}
		return EmptySeq()
	}

	func comparator() -> (AnyObject?, AnyObject?) -> NSComparisonResult {
		return _comp
	}

	func entryKey(entry: AnyObject) -> AnyObject? {
		return (entry as? IMapEntry)?.key()
	}

	func seq(ascending: Bool) -> ISeq? {
		if _count > 0 {
			return SortedTreeSeq.createWithRoot(_tree, ascending: ascending, count: _count)
		}
		return nil
	}

	func seqFrom(key: AnyObject, ascending: Bool) -> ISeq? {
		if _count > 0 {
			var stack: ISeq? = nil
			var t: TreeNode? = _tree
			while t != nil {
				let c: NSComparisonResult = self.doCompare(key, k2: t!.key()!)
				if c == .OrderedSame {
					stack = Utils.cons(t!, to: stack)
					return SortedTreeSeq(stack: stack, ascending: ascending)
				} else if ascending {
					if c == .OrderedSame {
						stack = Utils.cons(t!, to: stack)
						t = t?.left()
					} else {
						t = t?.right()
					}
				} else {
					if c == .OrderedSame {
						stack = Utils.cons(t!, to: stack)
						t = t?.right()
					} else {
						t = t?.left()
					}
				}
			}
			if stack != nil {
				return SortedTreeSeq(stack: stack, ascending: ascending)
			}
		}
		return nil
	}

	func minKey() -> AnyObject? {
		let t: TreeNode? = self.min()
		return t != nil ? t!.key() : nil
	}

	func min() -> TreeNode? {
		var t: TreeNode? = _tree
		if t != nil {
			while t!.left() != nil {
				t = t!.left()
			}
		}
		return t
	}

	func maxKey() -> AnyObject? {
		let t: TreeNode? = self.max()
		return t != nil ? t!.key() : nil
	}

	func max() -> TreeNode? {
		var t: TreeNode? = _tree
		if t != nil {
			while t!.right() != nil {
				t = t!.right()
			}
		}
		return t
	}

	func depth() -> Int32 {
		return self.depth(_tree)
	}

	func depth(t: TreeNode?) -> Int32 {
		if t == nil {
			return 0
		}
		let ll = self.depth(t!.left())
		let rr = self.depth(t!.right())
		return 1 + ((ll > rr) ? ll : rr)
	}

	override func objectForKey(key: AnyObject, def: AnyObject?) -> AnyObject? {
		let n: TreeNode? = self.entryForKey(key) as? TreeNode
		return (n != nil) ? n!.val() : def
	}

	override func objectForKey(key: AnyObject) -> AnyObject? {
		return self.objectForKey(key, def: nil)
	}

	func capacity() -> Int {
		return _count
	}

	override func count() -> UInt {
		return UInt(_count)
	}

	override func entryForKey(aKey: AnyObject) -> IMapEntry? {
		var t: TreeNode? = _tree
		while t != nil {
			let c: NSComparisonResult = self.doCompare(aKey, k2: t!.key()!)
			if c == .OrderedSame {
				return t
			} else if c == .OrderedDescending {
				t = t!.left()
			} else {
				t = t!.right()
			}
		}
		return t
	}

	func doCompare(k1: AnyObject,  k2: AnyObject) -> NSComparisonResult {
		return _comp(k1, k2)
	}

	func add(t: TreeNode?, key: AnyObject, val: AnyObject?, found: Box) -> TreeNode? {
		if t == nil {
			if val == nil {
				return RedTreeNode(k: key)
			}
			return RedTreeValue(key: key, val: val!)
		}
		let c: NSComparisonResult = self.doCompare(key, k2: t!.key()!)
		if c == .OrderedSame {
			found.val = t
			return nil
		}
		let ins: TreeNode? = c == .OrderedDescending ? self.add(t!.left(), key: key, val: val, found: found) : self.add(t!.right(), key: key, val: val, found: found)
		if ins == nil {
			return nil
		}
		if c == .OrderedDescending {
			return t!.addLeft(ins!)
		}
		return t!.addRight(ins!)
	}

	func remove(t: TreeNode?, key: AnyObject, found: Box) -> TreeNode? {
		if t == nil {
			return nil
		}
		let c: NSComparisonResult = self.doCompare(key, k2: t!.key()!)
		if c == .OrderedSame {
			found.val = t
			return PersistentTreeMap.append(t!.left()!, right: t!.right()!)
		}
		let del: TreeNode? = c == .OrderedDescending ? self.remove(t!.left(), key: key, found: found) : self.remove(t!.right(), key: key, found: found)
		if del == nil && found.val == nil {
			return nil
		}
		if c == .OrderedDescending {
			if let _ = t!.left() as? BlackTreeNode {
				return PersistentTreeMap.balanceLeftDel(t!.key()!, val: t!.val()!, del: del!, right: t!.right()!)
			} else {
				return PersistentTreeMap.red(t!.key()!, val: t!.val()!, left: del!, right: t!.right()!)
			}
		}

		if let _ = t!.right() as? BlackTreeNode {
			return PersistentTreeMap.balanceRightDel(t!.key()!, val: t!.val()!, del: del!, left: t!.left()!)
		}
		return PersistentTreeMap.red(t!.key()!, val: t!.val()!, left: t!.left()!, right: del!)
	}

	class func append(left: TreeNode?,  right: TreeNode?) -> TreeNode? {
		if left == nil {
			return right
		} else if right == nil {
			return left
		} else if let _ = left as? RedTreeNode {
			if let _ = right as? RedTreeNode {
				let app: TreeNode? = PersistentTreeMap.append(left!.right(), right: right!.left())
				if let _ = app as? RedTreeNode {
					return PersistentTreeMap.red(app!.key()!, val: app!.val(), left: PersistentTreeMap.red(left!.key()!, val: left!.val()!, left: left!.left()!, right: app!.left()!), right: PersistentTreeMap.red(right!.key()!, val: right!.val()!, left: app!.right(), right: right!.right()!))
				} else {
					return PersistentTreeMap.red(left!.key()!, val: left!.val()!, left: left!.left()!, right: PersistentTreeMap.red(right!.key()!, val: right!.val()!, left: app, right: right!.right()!))
				}
			} else {
				return PersistentTreeMap.red(left!.key()!, val: left!.val()!, left: left!.left()!, right: PersistentTreeMap.append(left!.right()!, right: right))
			}
		} else if let _ = right as? RedTreeNode {
			return PersistentTreeMap.red(right!.key()!, val: right!.val()!, left: PersistentTreeMap.append(left, right: right!.left()!), right: right!.right()!)
		} else {
			let app: TreeNode? = PersistentTreeMap.append(left!.right()!, right: right!.left()!)
			if let _ = app as? RedTreeNode {
				return PersistentTreeMap.red(app!.key()!, val: app!.val(), left: PersistentTreeMap.black(left!.key()!, val: left!.val()!, left: left!.left()!, right: app!.left()!), right: PersistentTreeMap.black(right!.key()!, val: right!.val()!, left: app!.right(), right: right!.right()!))
			} else {
				return PersistentTreeMap.balanceLeftDel(left!.key()!, val: left!.val()!, del: left!.left()!, right: PersistentTreeMap.black(right!.key()!, val: right!.val()!, left: app, right: right!.right()!))
			}
		}
	}

	class func balanceLeftDel(key: AnyObject, val: AnyObject, del: TreeNode, right: TreeNode) -> TreeNode? {
		if let _ = del as? RedTreeNode {
			return PersistentTreeMap.red(key, val: val, left: del.blacken(), right: right)
		} else if let _ = right as? BlackTreeNode {
			return PersistentTreeMap.rightBalance(key, val: val, left: del, ins: right.redden()!)
		} else if let _ = right as? RedTreeNode, let _ = right.left() as? BlackTreeNode {
			return PersistentTreeMap.red(right.left()!.key()!, val: right.left()!.val()!, left: PersistentTreeMap.black(key, val: val, left: del, right: right.left()!.left()!), right: PersistentTreeMap.rightBalance(right.key()!, val: right.val()!, left: right.left()!.right()!, ins: right.right()!.redden()!))
		} else {
			fatalError("Invariant violation")
		}
		return nil
	}

	class func balanceRightDel(key: AnyObject, val: AnyObject, del: TreeNode, left: TreeNode) -> TreeNode? {
		if let _ = del as? RedTreeNode {
			return PersistentTreeMap.red(key, val: val, left: left, right: del.blacken())
		} else if let _ = left as? BlackTreeNode {
			return PersistentTreeMap.leftBalance(key, val: val, ins: left.redden()!, right: del)
		} else if let _ = left as? RedTreeNode, let _ = left.right() as? BlackTreeNode {
			return PersistentTreeMap.red(left.right()!.key()!, val: left.right()!.val(), left: PersistentTreeMap.leftBalance(left.key()!, val: left.val()!, ins: left.left()!.redden()!, right: left.right()!.left()!), right: PersistentTreeMap.black(key, val: val, left: left.right()!.right(), right: del))
		} else {
			fatalError("Invariant violation")
		}
		return nil
	}

	class func leftBalance(key: AnyObject, val: AnyObject, ins: TreeNode, right: TreeNode) -> TreeNode? {
		if let _ = ins as? RedTreeNode, let _ = ins.left() as? RedTreeNode {
			return PersistentTreeMap.red(ins.key()!, val: ins.val(), left: ins.left()!.blacken()!, right: PersistentTreeMap.black(key, val: val, left: ins.right(), right: right))
		} else if let _ = ins as? RedTreeNode, let _ = ins.right() as? RedTreeNode {
			return PersistentTreeMap.red(ins.right()!.key()!, val: ins.right()!.val()!, left: PersistentTreeMap.black(ins.key()!, val: ins.val(), left: ins.left(), right: ins.right()!.left()!), right: PersistentTreeMap.black(key, val: val, left: ins.right()!.right()!, right: right))
		} else {
			return PersistentTreeMap.black(key, val: val, left: ins, right: right)
		}
	}

	class func rightBalance(key: AnyObject, val: AnyObject, left: TreeNode, ins: TreeNode) -> TreeNode? {
		if let _ = ins as? RedTreeNode, let _ = ins.right() as? RedTreeNode {
			return PersistentTreeMap.red(ins.key()!, val: ins.val(), left: PersistentTreeMap.black(key, val: val, left: left, right: ins.left()), right: ins.right()!.blacken()!)
		} else if let _ = ins as? RedTreeNode, let _ = left as? RedTreeNode {
			return PersistentTreeMap.red(ins.left()!.key()!, val: ins.left()!.val()!, left: PersistentTreeMap.black(key, val: val, left: left, right: ins.left()!.left()!), right: PersistentTreeMap.black(ins.key()!, val: ins.val(), left: ins.left()!.right()!, right: ins.left()!.val()! as? TreeNode))
		} else {
			return PersistentTreeMap.black(key, val: val, left: left, right: ins)
		}
	}

	func replace(t: TreeNode, key: AnyObject, val: AnyObject) -> TreeNode {
		let c: NSComparisonResult = self.doCompare(key, k2: t.key()!)
		return t.replaceKey(t.key()!, byValue: (c == .OrderedSame) ? val : t.val()!, left: (c == .OrderedDescending) ? self.replace(t.left()!, key: key, val: val) : t.left()!, right: (c == .OrderedAscending) ? self.replace(t.right()!, key: key, val: val) : t.right()!)!
	}

	class func red(key: AnyObject, val: AnyObject?, left: TreeNode?, right: TreeNode?) -> RedTreeNode {
		if left == nil && right == nil {
			if val == nil {
				return RedTreeNode(k: key)
			}
			return RedTreeValue(key: key, val: val!)
		}
		if val == nil {
			return RedTreeBranch(k: key, left: left!, right: right!)
		}
		return RedTreeBranchValue(key: key, val: val!, left: left!, right: right!)
	}

	class func black(key: AnyObject, val: AnyObject?, left: TreeNode?, right: TreeNode?) -> BlackTreeNode {
		if left == nil && right == nil {
			if val == nil {
				return BlackTreeNode(k: key)
			}
			return BlackTreeValue(key: key, val: val!)
		}
		if val == nil {
			return BlackTreeBranch(k: key, left: left!, right: right!)
		}
		return BlackTreeBranchValue(key: key, val: val!, left: left!, right: right!)
	}

	func meta() -> IPersistentMap? {
		return _meta
	}
}
