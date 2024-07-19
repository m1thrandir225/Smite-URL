//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 19.7.24.
//

import Foundation


func EncodeBase64(_ input: Data) -> String {
	let base64String = input.base64EncodedString()
	
	let urlSafeBase64String = base64String
		.replacingOccurrences(of: "+", with: "-")
		.replacingOccurrences(of: "/", with: "-")
		.replacingOccurrences(of: "=", with: "")
	return urlSafeBase64String
}
