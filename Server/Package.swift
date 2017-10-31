// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "WebStructTestServer",
    targets: [
        Target(name: "TestServer" ),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,3,0))
    ]
)
