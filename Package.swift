// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppsFlyerAdobeAEPExtension",
    platforms: [
            .iOS(.v12)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AppsFlyerAdobeAEPExtension",
            targets: ["AppsFlyerAdobeAEPExtension"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "AppsFlyerLib" , url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework-Static.git",  .exact("6.16.2")),
        .package(url: "https://github.com/adobe/aepsdk-core-ios.git", from: "3.0.0"),
        .package(url: "https://github.com/adobe/aepsdk-edge-ios.git", from: "3.0.0")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppsFlyerAdobeAEPExtension",
            dependencies: [ 
                            .product(name: "AEPIdentity", package: "aepsdk-core-ios"),
                            .product(name: "AEPCore", package: "aepsdk-core-ios"),
                            .product(name: "AEPLifecycle", package: "aepsdk-core-ios"),
                            .product(name: "AEPSignal", package: "aepsdk-core-ios"),
                            .product(name: "AEPEdge", package: "aepsdk-edge-ios"),
                            .product(name: "AppsFlyerLib-Static", package: "AppsFlyerLib")],
        path: "AppsFlyerAdobeExtension/Sources/"
),
    
        .testTarget(
            name: "AppsFlyerAdobeExtensionTests",
            dependencies: ["AppsFlyerAdobeAEPExtension"],
            path: "AppsFlyerAdobeExtension/Tests/"
)
    ]
)
