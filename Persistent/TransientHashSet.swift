//
//  TransientHashSet.swift
//  Persistent
//
//  Created by Robert Widmann on 12/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

class TransientHashSet: AbstractTransientSet {
	override func persistent() -> IPersistentCollection? {
		return PersistentHashSet(meta: nil, impl: _impl!.persistent())
	}
}
