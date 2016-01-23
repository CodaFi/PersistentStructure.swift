//
//  TransientHashMap.swift
//  Persistent
//
//  Created by Robert Widmann on 12/22/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public class TransientHashMap: AbstractTransientMap {
	private var _edit: NSThread?
	private var _root: INode?
	private var _count: Int = 0
	private var _hasNull: Bool = false
	private var _nullValue: AnyObject?
	private var _leafFlag: AnyObject? = nil

	convenience init(withMap m: PersistentHashMap) {
		self.init(onThread: NSThread.currentThread(), root: m.root, count: Int(m.count), hasNull: m.hasNull, nullValue: m.nullValue)
	}

	override init() { }

	init(onThread thread: NSThread?, root: INode?, count: Int, hasNull: Bool, nullValue: AnyObject) {
		_edit = thread
		_root = root
		_count = count
		_hasNull = hasNull
		_nullValue = nullValue
		_leafFlag = nil
	}

	override func doassociateKey(key: AnyObject,  val: AnyObject) -> ITransientMap {
		_leafFlag = nil
		let n: INode? = (_root ?? BitmapIndexedNode.empty).assocOnThread(_edit, shift: 0, hash: Int(Utils.hash(key)), key: key, val: val)
		if n !== _root {
			_root = n
		}
		if _leafFlag != nil {
			_count = _count.successor()
		}
		return self
	}

	override func doWithout(key: AnyObject) -> ITransientMap {
		guard let r = _root else {
			return self
		}
		
		_leafFlag = nil
		let n: INode? = r.withoutOnThread(_edit, shift: 0, hash: Int(Utils.hash(key)), key: key)
		if n !== _root {
			_root = n
		}
		if _leafFlag != nil {
			_count--
		}
		return self
	}

	override func doPersistent() -> IPersistentMap {
		return PersistentHashMap(count: _count, root: _root, hasNull: _hasNull, nullValue: _nullValue)
	}

	override func doobjectForKey(keye: AnyObject?,  notFound: AnyObject) -> AnyObject? {
		guard let key = keye else {
			if _hasNull {
				return _nullValue
			} else {
				return notFound
			}
		}
		
		guard let r = _root else {
			return notFound
		}
		
		return r.findWithShift(0, hash: Int(Utils.hash(key)), key: key, notFound: notFound)
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
