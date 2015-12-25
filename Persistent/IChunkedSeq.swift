//
//  IChunkedSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IChunkedSeq : ISeq, ISequential {
	func chunkedFirst() -> IChunk?
	func chunkedNext() -> ISeq
	func chunkedMore() -> ISeq
}
