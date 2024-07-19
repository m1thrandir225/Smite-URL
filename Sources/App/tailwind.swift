//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 19.7.24.
//
import SwiftyTailwind
import TSCBasic
import Vapor

func tailwind(_ app: Application) async throws {
  let resourcesDirectory = try AbsolutePath(validating: app.directory.resourcesDirectory)
  let publicDirectory = try AbsolutePath(validating: app.directory.publicDirectory)

  let tailwind = SwiftyTailwind()
  try await tailwind.run(
	input: .init(validating: "Styles/app.css", relativeTo: resourcesDirectory),
	output: .init(validating: "styles/app.generated.css", relativeTo: publicDirectory),
	options: .content("\(app.directory.viewsDirectory)/**/*.leaf")
  )
}
