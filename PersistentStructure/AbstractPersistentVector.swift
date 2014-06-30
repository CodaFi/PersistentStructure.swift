//
//  AbstractPersistentVector.swift
//  PersistentStructure
//
//  Created by Robert Widmann on 6/29/14.
//  Copyright (c) 2014 CodaFi. All rights reserved.
//

import Foundation

class AbstractPersistentVector : IPersistentVector, IRandomAccess, IComparable, IHashEqable {
	var _hash : Int
	var _hasheq : Int
	
	init() {
		_hash = -1
		_hasheq = -1
	}
	
	func seq() -> ISequence? {
		if count() > 0 {
			//		return [[CLJVecSeq alloc] initWithVector:self index:0];
		}
		return nil
	}
	
	func reversedSeq() -> ISequence? {
		if count() > 0 {
			return [[CLJRVecSeq alloc] initWithVector:self index:self.count - 1];
		}
		return nil;
	}
}
