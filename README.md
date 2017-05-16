# WebStruct
[![CocoaPods compatible](https://img.shields.io/badge/pod(central free)-compatible-blue.svg)](#)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-orange.svg)](#)
[![GitHub release](https://img.shields.io/github/release/iq3AddLi/WebStruct.svg)](https://github.com/iq3AddLi/WebStruct/releases)
![Swift 3.1](https://img.shields.io/badge/Swift-3.1-orange.svg)
![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)

This library is initalize Swift struct from Web API.
It is made of very proper and lazy.
It can be used only when the following conditions are satisfied.

* When request format is JSON.😞
* When API response format is JSON.😥
* When I was prepared to be unable to use a kind JSON Parser.😰
* If you want to process asynchronously, use GCD.😇


# Usage

## Implement WebInitializable of Struct for API Response


```Swift
// Basic pattern
struct BasicStruct {
    let message:String
}

extension BasicStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError

    static var path = "http://localhost:8080/basic"
    
    init (fromJson json:Any) throws{
        guard case let dic as [String:Any] = json
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let message as String = dic["message"]
            else { throw ParseError(code: -1, reason: "Message is not found.") }
        
        self.message = message
    }
}
```

## Implement WebDeserializable of Struct for API Request

```Swift
struct TestParam {
    let param:String
}

extension TestParam : WebDeserializable {
    func toJsonData() -> Any{
        return [ "param" : param ]
    }
}
```

## Implement Parse Error & API Error

```Swift
struct ParseError : Swift.Error{
    let code:Int
    let reason:String
}

struct ApplicationError : Swift.Error{
    let code:Int
    let reason:String
}

extension ApplicationError : WebSerializable{
    init (fromJson json:Any) throws{
        guard case let dic as [String:Any] = json
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
let basic = try? BasicStruct( TestParam(param: "hoge") )
```

# Customize

You can customize the behavior by implementing timeout and configuration.

## Want to extend the timeout
```Swift
extension CustomStruct : WebInitializable {
    ...
    static var timeout = 10
    ...
}
```

## Want to custom URLSessionConfiguration
```Swift
extension CustomStruct : WebInitializable {
    ...
    static var configuration:URLSessionConfiguration {
        let def = URLSessionConfiguration.default
        def.allowsCelluarAccess = false // celluar access disabled 
        return def
    }
    ...
}
```
## Want to change HTTP method
```Swift
extension CustomStruct : WebInitializable {
    ...
    static var method = "OPTIONS"
    ...
}
```
## Want to add HTTP headers
```Swift
extension CustomStruct : WebInitializable {
    ...
    static var headers = [
        "hello" : "world"
    ]
    ...
}
```

# known Issues
* There was a problem that a segmentation fault occurred when used with Ubuntu.
* I looked up this problem is solved on DEVELOPMENT-SNAPSHOT-2017-02-09-a.
