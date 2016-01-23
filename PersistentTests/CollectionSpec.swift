//
//  CollectionSpec.swift
//  Persistent
//
//  Created by Robert Widmann on 1/23/16.
//  Copyright © 2016 TypeLift. All rights reserved.
//

import SwiftCheck
@testable import Persistent

class CollectionSpec : XCTestCase {
	func testCollections() {
		property("Empty collections have 0 count") <- forAll { (x : PersistentQueue) in
			return x.isEmpty ==> x.count == 0
		}
	}
}
