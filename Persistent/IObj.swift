//
//  IObj.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol IObj {
	func withMeta(meta: IPersistentMap?) -> IObj
}
