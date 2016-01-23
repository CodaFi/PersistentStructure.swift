//
//  Arbitrary.swift
//  Persistent
//
//  Created by Robert Widmann on 1/23/16.
//  Copyright © 2016 TypeLift. All rights reserved.
//

import SwiftCheck
import Persistent

extension PersistentVector : Arbitrary {
	public static var arbitrary : Gen<PersistentVector> {
		return Gen<PersistentVector>.oneOf([
			Gen<PersistentVector>.pure(PersistentVector())
		])
	}
}

extension TransientVector : Arbitrary {
	public static var arbitrary : Gen<TransientVector> {
		return Gen<TransientVector>.oneOf([
			Gen<TransientVector>.pure(TransientVector())
		])
	}
}

extension PersistentQueue : Arbitrary {
	public static var arbitrary : Gen<PersistentQueue> {
		return Gen<PersistentQueue>.oneOf([
			Gen<PersistentQueue>.pure(PersistentQueue())
		])
	}
}