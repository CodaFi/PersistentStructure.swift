//
//  TransientHashMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class TransientHashMap: AbstractTransientMap {
	private var _edit: NSThread?
	private var _root: INode?
	private var _count: Int = 0
	private var _hasNull: Bool = false
	private var _nullValue: AnyObject?
	private var _leafFlag: Box = Box()

	class func create(m: PersistentHashMap) -> TransientHashMap {
		return TransientHashMap.createOnThread(NSThread.currentThread(), root: m.root(), count: Int(m.count()), hasNull: m.hasNull(), nullValue: m.nullValue())
	}

	override init() { }

	class func createOnThread(thread: NSThread?, root: INode?, count: Int, hasNull: Bool, nullValue: AnyObject) -> TransientHashMap {
		let map: TransientHashMap = TransientHashMap()
		map._edit = thread
		map._root = root
		map._count = count
		map._hasNull = hasNull
		map._nullValue = nullValue
		map._leafFlag = Box()
		return map
	}

	override func doassociateKey(key: AnyObject?,  val: AnyObject?) -> ITransientMap? {
		if key == nil {
			if _nullValue !== val {
				_nullValue = val
			}
			if !_hasNull {
				_count = _count.successor()
				_hasNull = true
			}
			return self
		}
		_leafFlag.val = nil
		let n: INode? = (_root == nil ? BitmapIndexedNode.empty() : _root)!.assocOnThread(_edit, shift: 0, hash: Int(Utils.hash(key)), key: key!, val: val!, addedLeaf: _leafFlag)
		if n !== _root {
			_root = n
		}
		if _leafFlag.val != nil {
			_count = _count.successor()
		}
		return self
	}

	override func doWithout(key: AnyObject?) -> ITransientMap? {
		if key == nil {
			if !_hasNull {
				return self
			}
			_hasNull = false
			_nullValue = nil
			_count--
			return self
		}
		if _root == nil {
			return self
		}
		_leafFlag.val = nil
		let n: INode? = _root!.withoutOnThread(_edit, shift: 0, hash: Int(Utils.hash(key)), key: key!, addedLeaf: _leafFlag)
		if n !== _root {
			_root = n
		}
		if _leafFlag.val != nil {
			_count--
		}
		return self
	}

	override func doPersistent() -> IPersistentMap {
		return PersistentHashMap(count: UInt(_count), root: _root, hasNull: _hasNull, nullValue: _nullValue)
	}

	override func doobjectForKey(key: AnyObject?,  notFound: AnyObject) -> AnyObject? {
		if key == nil {
			if _hasNull {
				return _nullValue!
			} else {
				return notFound
			}
		}
		if _root == nil {
			return notFound
		}
		return _root!.findWithShift(0, hash: Int(Utils.hash(key)), key: key!, notFound: notFound)
	}


	override func doCount() -> Int {
		return _count
	}

	override func ensureEditable() {
		if _edit == NSThread.currentThread() {
			return
		}
		if _edit != nil {
			fatalError("Transient used by non-owner thread")
		}
		fatalError("Transient used by call to be persistent")
	}
}
