//
//  ITransientVector.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol ITransientVector : ITransientAssociative, IIndexed {
	func assocN(i : Int, value : AnyObject) -> ITransientVector
	func pop() -> ITransientVector?
}
