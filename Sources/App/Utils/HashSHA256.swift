//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 19.7.24.
//

import Foundation
import Vapor

extension Digest {
	var bytes: [UInt8] { Array(makeIterator())}
	var data: Data { Data(bytes)}
	
	var hexStr: String {
		bytes.map {
			String(format: "%02X", $0)
		}.joined()
	}
}



func HashSHA256(input: String) -> Data {
	let dataFromString = input.data(using: .utf8)!
	let digest = SHA256.hash(data: dataFromString)
	
	return digest.data
}
