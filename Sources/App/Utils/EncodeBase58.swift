//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 22.7.24.
//

import Foundation
import Base58

func EncodeBase58(_ input: Data) -> String {
	let bytes = [UInt8](input)
	let encodedString = Base58.Encode(bytes)
	
	return encodedString
}
