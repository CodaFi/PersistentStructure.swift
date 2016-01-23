//
//  IChunkedSeq.swift
//  Persistent
//
//  Created by Robert Widmann on 11/15/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

protocol IChunkedSeq : ISeq, ISequential {
	var chunkedFirst : IChunk? { get }
	var chunkedNext : ISeq { get }
	var chunkedMore : ISeq { get }
}
