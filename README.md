# WebStruct
[![GitHub release](https://img.shields.io/github/release/iq3AddLi/WebStruct.svg)](https://github.com/iq3AddLi/WebStruct/releases)
[![CocoaPods compatible](https://img.shields.io/badge/pod_direct_only-compatible-blue.svg)](#)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](#)
![Swift 3.1](https://img.shields.io/badge/Swift-3.1-orange.svg)
![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

This library is initalize Swift struct from Web API.
It is made of very proper and lazy.
It can be used only when the following conditions are satisfied.

* ~~When request format is JSON~~ .
* ~~When API response format is JSON~~ .
* ~~When I was prepared to be unable to use a kind JSON Parser~~.
* If you want to process asynchronously, use GCD.😇


# Usage

## Implement WebInitializable of Struct for API Response


```Swift
// Basic pattern
struct BasicStruct {
    let message:String
}

extension BasicStruct : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError

    static var path = "http://localhost:8080/basic"
    
    init (fromObject object:Any) throws{
        guard case let dic as [String:Any] = object
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let message as String = dic["message"]
            else { throw ParseError(code: -1, reason: "Message is not found.") }
        
        self.message = message
    }
}
```

## Implement WebDeserializable of Struct for API Request

```Swift
struct RequestStruct {
    let value:String
}

extension RequestStruct : WebDeserializable {
    func toObject() -> Any{
        return [ "key" : value ]
    }
}
```

## Implement Parse Error & API Error

```Swift
// Error type
struct ParseError : Swift.Error{
    let code:Int
    let reason:String
}

struct ApplicationError : Swift.Error{
    let code:Int
    let reason:String
}


extension ApplicationError : WebSerializable{
    init (fromObject object:Any) throws{
        guard case let dic as [String:Any] = object
            else{ throw ParseError(code: 0, reason: "") }
        
        guard case let error as [String:Any] = dic["error"]
            else{ throw ParseError(code: 0, reason: "") }
        
        guard case let code as Int = error["code"]
            else{ throw ParseError(code: 0, reason: "") }
        self.code = code
        
        guard case let reason as String = error["reason"]
            else{ throw ParseError(code: 0, reason: "") }
        self.reason = reason
    }
}
```

## Struct Initialize

```Swift
let basic = try? BasicStruct( RequestStruct(value: "hello") )
```
### Error Handled 
```Swift
do{
    let _ = try ErrorStruct( RequestStruct(value: "hello") )
}
catch let error as WebStruct.Error{
    switch (error) {
    case .network(let _):
        // Network error
        XCTAssert( false,"Unexpected error.")
    case .http(let _):
        // HTTP error
        XCTAssert( false,"Unexpected error.")
    case .ignoreData:
        // Unexpected response data
        XCTAssert( false,"Unexpected error.")
    case .parse(let _):
        // Failed parse response data
        XCTAssert( false,"Unexpected error.")
    case .application(let e):
        // Server side defined error
        XCTAssert( e is ApplicationError, "ApplicationError serialize is fail")
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

# known Issues
* There was a problem that a segmentation fault occurred when used with Ubuntu.
* I looked up this problem is solved on DEVELOPMENT-SNAPSHOT-2017-02-09-a.
