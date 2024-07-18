//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 18.7.24.
//

import Vapor


struct ShortURL: Content {
	let initialURL: String
	let shortURL: String
}
