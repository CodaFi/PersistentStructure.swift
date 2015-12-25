//
//  IIndexedSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IIndexedSeq : ISeq, ISequential, ICounted {
	func index() -> Int
}
