// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "WebStructTestServer",
    targets: [
        Target(name: "TestServer" ),
    ],
    dependencies: [
        .Package(url: "https://github.com/qutheory/vapor.git", Version(1,5,15))
    ]
)
