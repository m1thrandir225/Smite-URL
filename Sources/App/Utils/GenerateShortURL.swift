//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 19.7.24.
//

import Foundation
import BigInt


func generateShortURL(initialLink: String) -> String {
	let combinedString = initialLink
	let urlHashBytes = HashSHA256(input: combinedString)
	let generatedNumber = BigUInt(urlHashBytes).description
	
	let generatedBytes = Data(generatedNumber.utf8)
	let finalString = EncodeBase64(generatedBytes)
	return  String(finalString.prefix(8))
}
