//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 18.7.24.
//

import Foundation
import Vapor


struct CreateShortURLRequest: Content {
	var url: String
}
