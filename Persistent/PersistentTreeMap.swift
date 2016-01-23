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

	init(comp: (AnyObject?, AnyObject?) -> NSComparisonResult, tree: TreeNode?, count: Int, meta: IPersistentMap) {
		_meta = meta
		_comp = comp
		_tree = tree
		_count = count
		super.init()
	}

	class func empty() -> IPersistentCollection {
		return EMPTY
	}

	class func create(other: IMap?) -> IPersistentMap {
		var ret: IPersistentMap = EMPTY as IPersistentMap
		for o: AnyObject in other!.allEntries().generate() {
			let e: MapEntry = o as! MapEntry
			ret = ret.associateKey(e.key(), withValue: e.val()) as! IPersistentMap
		}
		return ret
	}

	class func empty() -> PersistentTreeMap {
		return EMPTY
	}

	func withMeta(meta: IPersistentMap?) -> IObj {
		return PersistentTreeMap(meta: meta, comparator: _comp, tree: _tree, count: _count)
	}

	convenience init(comparator: (AnyObject?, AnyObject?) -> NSComparisonResult) {
		self.init(meta: nil, comparator: comparator)
	}

	class func createWithSeq(var items: ISeq?) -> AnyObject {
		var ret: IPersistentMap = EMPTY
		for ; items != nil; items = items!.next().next() {
			if items?.next() == nil {
				fatalError("No value supplied for key: \(items!.first)")
			}
			ret = ret.associateKey(items!.first()!, withValue: Utils.second(items!)!) as! PersistentTreeMap
		}
		return ret as! PersistentTreeMap
	}

	class func createWithComparator(comp: (AnyObject?, AnyObject?) -> NSComparisonResult, var seq items: ISeq?) -> AnyObject {
		var ret: IPersistentMap = PersistentTreeMap(comparator: comp)
		for ; items != nil; items = items!.next().next() {
			if items!.next().count == 0 {
				fatalError("No value supplied for key: \(items!.first)")
			}
			ret = ret.associateKey(items!.first()!, withValue: Utils.second(items!)!) as! PersistentTreeMap
		}
		return ret as! PersistentTreeMap
	}

	override func containsKey(key: AnyObject) -> Bool {
		return self.objectForKey(key) != nil
	}

	func assocEx(key: AnyObject, value val: AnyObject) -> IPersistentMap {
		let (t, _) = self.add(_tree, key: key, val: val)
		if t == nil {
			fatalError("Key already present")
		}
		return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: t?.blacken(), count: _count + 1)
	}

	func associateKey(key: AnyObject, value val: AnyObject) -> IPersistentMap {
		let (t, foundNode) = self.add(_tree, key: key, val: val)
		if t == nil {
			if foundNode?.val() === val {
				return self
			}
			return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: self.replace(_tree!, key: key, val: val), count: _count + 1)
		}
		return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: t?.blacken(), count: _count + 1)
	}

	override func without(key: AnyObject) -> IPersistentMap {
		let (t, found) = self.remove(_tree, key: key)
		if let tn = t {
			return PersistentTreeMap(meta: self.meta(), comparator: _comp, tree: tn.blacken(), count: _count - 1)
		} else if found == nil {
			return self
		} else {
			return PersistentTreeMap(meta: self.meta(), comparator: _comp)
		}
	}

	override func seq() -> ISeq {
		if _count > 0 {
			return SortedTreeSeq(withRoot: _tree, ascending: true, count: _count)
		}
		return EmptySeq()
	}

	func reversedSeq() -> ISeq {
		if _count > 0 {
			return SortedTreeSeq(withRoot: _tree, ascending: false, count: _count)
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
			return SortedTreeSeq(withRoot: _tree, ascending: ascending, count: _count)
		}
		return nil
	}

	func seqFrom(key: AnyObject, ascending: Bool) -> ISeq? {
		if _count > 0 {
			var stack: ISeq = EmptySeq()
			var t: TreeNode? = _tree
			while t != nil {
				let c: NSComparisonResult = self.doCompare(key, k2: t!.key())
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
			return SortedTreeSeq(stack: stack, ascending: ascending)
		}
		return nil
	}

	func minKey() -> AnyObject? {
		return self.min()?.key()
	}

	func min() -> TreeNode? {
		if var t = _tree {
			while let left = t.left() {
				t = left
			}
			return t
		}
		return nil
	}

	func maxKey() -> AnyObject? {
		return self.max()?.key()
	}

	func max() -> TreeNode? {
		if var t = _tree {
			while let right = t.right() {
				t = right
			}
			return t
		}
		return nil
	}

	func depth() -> Int32 {
		return self.depth(_tree)
	}

	func depth(tn: TreeNode?) -> Int32 {
		guard let t = tn else {
			return 0
		}
		
		let ll = self.depth(t.left())
		let rr = self.depth(t.right())
		return 1 + ((ll > rr) ? ll : rr)
	}

	override func objectForKey(key: AnyObject, def: AnyObject) -> AnyObject {
		if let n = self.entryForKey(key) as? TreeNode {
			return n.val()
		}
		return def
	}

	override func objectForKey(key: AnyObject) -> AnyObject? {
		if let n = self.entryForKey(key) as? TreeNode {
			return n.val()
		}
		return nil
	}

	func capacity() -> Int {
		return _count
	}

	override var count : Int {
		return _count
	}

	override func entryForKey(aKey: AnyObject) -> IMapEntry? {
		var t: TreeNode? = _tree
		while t != nil {
			let c: NSComparisonResult = self.doCompare(aKey, k2: t!.key())
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

	func add(treen: TreeNode?, key: AnyObject, val: AnyObject?) -> (TreeNode?, oldValue: TreeNode?) {
		guard let t = treen else {
			if val == nil {
				return (RedTreeNode(k: key), nil)
			}
			return (RedTreeValue(key: key, val: val!), nil)
		}
		let c: NSComparisonResult = self.doCompare(key, k2: t.key())
		if c == .OrderedSame {
			return (nil, t)
		}
		let (inse, found) = (c == .OrderedDescending) ? self.add(t.left(), key: key, val: val) : self.add(t.right(), key: key, val: val)
		guard let ins = inse else {
			return (nil, found)
		}
		
		if c == .OrderedDescending {
			return (t.addLeft(ins), found)
		}
		return (t.addRight(ins), found)
	}

	func remove(treen: TreeNode?, key: AnyObject) -> (TreeNode?, oldValue: TreeNode?) {
		guard let t = treen else {
			return (nil, nil)
		}
		
		let c: NSComparisonResult = self.doCompare(key, k2: t.key())
		if c == .OrderedSame {
			return (PersistentTreeMap.append(t.left()!, right: t.right()!), t)
		}
		
		let (dele, found) = (c == .OrderedDescending) ? self.remove(t.left(), key: key) : self.remove(t.right(), key: key)
		guard let del = dele else {
			return (nil, nil)
		}
		
		if c == .OrderedDescending {
			if let _ = t.left() as? BlackTreeNode {
				return (PersistentTreeMap.balanceLeftDel(t.key(), val: t.val(), del: del, right: t.right()!), found)
			} else {
				return (PersistentTreeMap.red(t.key(), val: t.val(), left: del, right: t.right()!), found)
			}
		}

		if let _ = t.right() as? BlackTreeNode {
			return (PersistentTreeMap.balanceRightDel(t.key(), val: t.val(), del: del, left: t.left()!), found)
		}
		return (PersistentTreeMap.red(t.key(), val: t.val(), left: t.left()!, right: del), found)
	}

	class func append(le: TreeNode?, right ri: TreeNode?) -> TreeNode? {
		if le == nil {
			return ri
		} else if ri == nil {
			return le
		} else if let left = le as? RedTreeNode {
			if let right = ri as? RedTreeNode {
				let app: TreeNode? = PersistentTreeMap.append(left.right(), right: right.left())
				if let _ = app as? RedTreeNode {
					return PersistentTreeMap.red(app!.key(), val: app!.val(), left: PersistentTreeMap.red(left.key(), val: left.val(), left: left.left()!, right: app!.left()!), right: PersistentTreeMap.red(right.key(), val: right.val(), left: app!.right(), right: right.right()!))
				} else {
					return PersistentTreeMap.red(left.key(), val: left.val(), left: left.left()!, right: PersistentTreeMap.red(right.key(), val: right.val(), left: app, right: right.right()!))
				}
			} else {
				return PersistentTreeMap.red(left.key(), val: left.val(), left: left.left()!, right: PersistentTreeMap.append(left.right()!, right: ri))
			}
		} else if let right = ri as? RedTreeNode {
			return PersistentTreeMap.red(right.key(), val: right.val(), left: PersistentTreeMap.append(le, right: right.left()!), right: right.right()!)
		} else {
			let appe: TreeNode? = PersistentTreeMap.append(le!.right()!, right: ri!.left()!)
			if let app = appe as? RedTreeNode {
				return PersistentTreeMap.red(app.key(), val: app.val(), left: PersistentTreeMap.black(le!.key(), val: le!.val(), left: le!.left()!, right: app.left()!), right: PersistentTreeMap.black(ri!.key(), val: ri!.val(), left: app.right(), right: ri!.right()!))
			} else {
				return PersistentTreeMap.balanceLeftDel(le!.key(), val: le!.val(), del: le!.left()!, right: PersistentTreeMap.black(ri!.key(), val: ri!.val(), left: appe, right: ri!.right()!))
			}
		}
	}

	class func balanceLeftDel(key: AnyObject, val: AnyObject, del: TreeNode, right ri: TreeNode) -> TreeNode? {
		if let _ = del as? RedTreeNode {
			return PersistentTreeMap.red(key, val: val, left: del.blacken(), right: ri)
		} else if let right = ri as? BlackTreeNode {
			return PersistentTreeMap.rightBalance(key, val: val, left: del, ins: right.redden())
		} else if let right = ri as? RedTreeNode, let rileft = right.left() as? BlackTreeNode {
			return PersistentTreeMap.red(rileft.key(), val: rileft.val(), left: PersistentTreeMap.black(key, val: val, left: del, right: rileft.left()!), right: PersistentTreeMap.rightBalance(right.key(), val: right.val(), left: rileft.right()!, ins: right.right()!.redden()!))
		} else {
			fatalError("Invariant violation")
		}
		return nil
	}

	class func balanceRightDel(key: AnyObject, val: AnyObject, del: TreeNode, left le: TreeNode) -> TreeNode? {
		if let _ = del as? RedTreeNode {
			return PersistentTreeMap.red(key, val: val, left: le, right: del.blacken())
		} else if let left = le as? BlackTreeNode {
			return PersistentTreeMap.leftBalance(key, val: val, ins: left.redden(), right: del)
		} else if let left = le as? RedTreeNode, let leright = left.right() as? BlackTreeNode {
			return PersistentTreeMap.red(leright.key(), val: leright.val(), left: PersistentTreeMap.leftBalance(left.key(), val: left.val(), ins: left.left()!.redden()!, right: leright.left()!), right: PersistentTreeMap.black(key, val: val, left: leright.right(), right: del))
		} else {
			fatalError("Invariant violation")
		}
		return nil
	}

	class func leftBalance(key: AnyObject, val: AnyObject, ins: TreeNode, right: TreeNode) -> TreeNode? {
		if let _ = ins as? RedTreeNode, let le = ins.left() as? RedTreeNode {
			return PersistentTreeMap.red(ins.key(), val: ins.val(), left: le.blacken()!, right: PersistentTreeMap.black(key, val: val, left: ins.right(), right: right))
		} else if let _ = ins as? RedTreeNode, let ri = ins.right() as? RedTreeNode {
			return PersistentTreeMap.red(ri.key(), val: ri.val(), left: PersistentTreeMap.black(ins.key(), val: ins.val(), left: ins.left(), right: ri.left()!), right: PersistentTreeMap.black(key, val: val, left: ri.right()!, right: right))
		} else {
			return PersistentTreeMap.black(key, val: val, left: ins, right: right)
		}
	}

	class func rightBalance(key: AnyObject, val: AnyObject, left: TreeNode, ins: TreeNode) -> TreeNode? {
		if let _ = ins as? RedTreeNode, let _ = ins.right() as? RedTreeNode {
			return PersistentTreeMap.red(ins.key(), val: ins.val(), left: PersistentTreeMap.black(key, val: val, left: left, right: ins.left()), right: ins.right()!.blacken()!)
		} else if let _ = ins as? RedTreeNode, let _ = left as? RedTreeNode {
			return PersistentTreeMap.red(ins.left()!.key(), val: ins.left()!.val(), left: PersistentTreeMap.black(key, val: val, left: left, right: ins.left()!.left()!), right: PersistentTreeMap.black(ins.key(), val: ins.val(), left: ins.left()!.right()!, right: ins.left()!.val() as? TreeNode))
		} else {
			return PersistentTreeMap.black(key, val: val, left: left, right: ins)
		}
	}

	func replace(t: TreeNode, key: AnyObject, val: AnyObject) -> TreeNode {
		let c: NSComparisonResult = self.doCompare(key, k2: t.key())
		return t.replaceKey(t.key(), byValue: (c == .OrderedSame) ? val : t.val(), left: (c == .OrderedDescending) ? self.replace(t.left()!, key: key, val: val) : t.left()!, right: (c == .OrderedAscending) ? self.replace(t.right()!, key: key, val: val) : t.right()!)!
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
