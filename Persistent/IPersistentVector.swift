//
//  IPersistentVector.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IPersistentVector : class, IAssociative, ISequential, IPersistentStack, IReversible, IIndexed {
	func assocN(i : Int, value : AnyObject) -> IPersistentVector?
	func cons(o : AnyObject) -> IPersistentVector?
}
