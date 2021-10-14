// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "X-Library",
	platforms: [.iOS(.v9)],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "X-Library",	// -> this is library's name to add to a project
			targets: ["XLibrary"]),	// -> these are modules to import in swift
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(name: "Facebook", url: "https://github.com/facebook/facebook-ios-sdk", from: "11.2.1"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "XLibrary",
			dependencies: ["nanopb", "PromisesObjC", "GoogleUtilities", "GoogleAppMeasurement", "UserMessagingPlatform", "GoogleMobileAds",
						   "UnityAds",
						   .product(name: "FacebookCore", package: "Facebook"),
						   .product(name: "FacebookLogin", package: "Facebook")],
			path: "Sources/X-Library"
			// sources: ["", "class", "libs", "common"]
			// linkerSettings: [.unsafeFlags(["-ObjC"])]
		),
		.testTarget(
			name: "X-LibraryTests",
			dependencies: ["XLibrary"]),
		.binaryTarget(
			name: "nanopb",
			path: "libs/nanopb.xcframework"
		),
		.binaryTarget(
			name: "PromisesObjC",
			path: "libs/PromisesObjC.xcframework"
		),
		.binaryTarget(
			name: "GoogleUtilities",
			path: "libs/GoogleUtilities.xcframework"
		),
		.binaryTarget(
			name: "GoogleAppMeasurement",
			path: "libs/GoogleAppMeasurement.xcframework"
		),
		.binaryTarget(
			name: "UserMessagingPlatform",
			path: "libs/UserMessagingPlatform.xcframework"
		),
		.binaryTarget(
			name: "GoogleMobileAds",
			path: "libs/GoogleMobileAds.xcframework"
		),
		.binaryTarget(
			name: "UnityAds",
			path: "libs/UnityAds.xcframework"
		)
	]
//	cLanguageStandard: .c99,
//	cxxLanguageStandard: .gnucxx14
)
