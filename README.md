# WebStruct
[![GitHub release](https://img.shields.io/github/release/iq3AddLi/WebStruct.svg)](https://github.com/iq3AddLi/WebStruct/releases)
[![CircleCI](https://circleci.com/gh/iq3addLi/WebStruct/tree/master.svg?style=shield)](https://circleci.com/gh/iq3addLi/WebStruct/tree/master)
[![CocoaPods compatible](https://img.shields.io/badge/pod_direct_only-compatible-blue.svg)](#)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](#)
![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg)
![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)



This library is initalize Swift struct from Web API.
It is made of very proper and lazy.
It can be used only when the following conditions are satisfied.

* ~~When request format is JSON~~ .
* ~~When API response format is JSON~~ .
* ~~When I was prepared to be unable to use a kind JSON Parser~~.
* If you want to process asynchronously, use GCD.😇

I used Codable from 0.7.0. No need for Any to Object processing.

# Usage

## Implement WebInitializable of Struct for API Response


```Swift
// Basic pattern
public struct BasicStruct : Decodable{
    let message:String
}
extension BasicStruct : WebInitializable {
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
}
```

## Implement WebDeserializable of Struct for API Request

```Swift
// Body struct
public struct RequestStruct : Encodable{
    let value:String
}
extension RequestStruct : WebDeserializable {
}
```

## Implement Parse Error & API Error

```Swift
public struct ApplicationError : Swift.Error, Decodable{
    let code:Int
    let reason:String
}
extension ApplicationError : WebSerializable{
}
```

## Struct Initialize

```Swift
let basic = try? BasicStruct(
    "http://localhost:8080/basic",
    body: RequestStruct(value: "hello")
)
```

### Error Handled 
```Swift
do{
    let _ = try ErrorStruct(
        "http://localhost:8080/error",
        body: RequestStruct(value: "hello")
    )
}
catch let error as WebStruct.Error{
    switch (error) {
    case .network( _):
        // Network error
        XCTAssert( false,"Network error is unexpected.")
    case .http( _):
        // HTTP error
        XCTAssert( false,"HTTP error is unexpected.")
    case .ignoreData:
        // Unexpected response data
        XCTAssert( false,"IgnoreData error is unexpected.")
    case .parse( _):
        // Failed parse response data
        XCTAssert( false,"Parse error is unexpected.")
    case .application(let e):
        // Server side defined error
        XCTAssert( e is ApplicationError, "Serialize for ApplicationError is fail.")
    }
}
catch {
    // Unexpected throws
    XCTAssert( false,"Unexpected error.")
}
```

# Customize
You can customize the behavior by implementing request and session.

## Customize request
```Swift
// TimeoutInterval extended
extension CustomRequestStruct : WebInitializable {
    ...
	static var request:URLRequest {
        guard let url = URL(string: CustomRequestStruct.path ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:10.0 )
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        return request
    }
    ...
}
```

## Customize session
```Swift
// Cellular access disabled
extension CustomSessionStruct : WebInitializable {
    ...
    static var session:URLSession {
        let def = URLSessionConfiguration.default
        def.allowsCellularAccess = false
        return URLSession(configuration: def, delegate: nil, delegateQueue: nil)
    }
    ...
}
```

# Testing

## Swift build in Server
```
cd Server
swift package clean
swift package update
```

## Generate Xcode project
```
swift package generate-xcodeproj
```

## Launch Test Server
```
open WebStructTestServer.xcodeproj
```
Build & Run "TestServer" Target in Xcode.

or
```
.build/debug/TestServer
```

## Run UnitTest for WebStruct
Command & U in WebStruct.xcodeproj


# Old Issues
* There was a problem that a segmentation fault occurred when used with Ubuntu.
* I looked up this problem is solved on DEVELOPMENT-SNAPSHOT-2017-02-09-a.
