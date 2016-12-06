# WebStruct
This library is initalize Swift struct from Web API.
It is made of very proper and lazy.
It can be used only when the following conditions are satisfied.

* When request format is JSON.😞
* When API response format is JSON.😥
* When I was prepared to be unable to use a kind JSON Parser.😰
* If you want to process asynchronously, use GCD.😇

```
⚠️ Do not use this library yet on Linux. See known Issues.
```

# Usage

## Implement WebInitializable of Struct for API Response


```Swift
struct DummyStruct {
    let message:String
}

extension DummyStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError

    static var path = "http://localhost:8080/dummy"
    
    init (fromJson:Any) throws{
        guard case let json as [String:Any] = fromJson
            else { throw ParseError(code: -1, reason: "not dictionary") }
        
        guard case let message as String = json["message"]
            else { throw ParseError(code: -1, reason: "message not found.") }
        
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
    init (fromJson:Any) throws{
        guard case let dic as [String:Any] = fromJson
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
let dummy = try? DummyStruct.get( TestParam(param: "hoge") )
```

# Customize

You can customize the behavior by implementing timeout and configuration.

```Swift
extension CustomStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError
    
    static var path = "http://localhost:8080/timeout"
    
    static var timeout:TimeInterval = 10
    static var configuration:URLSessionConfiguration {
        let def = URLSessionConfiguration.default
        def.allowsCelluarAccess = false
        return def
    }
    
    init (fromJson:Any) throws{
        
    }
}
```
# known Issues
* Using this library on Linux will fail to pass memory between threads. The contents of optional will be destroyed and segmentation fault will occur. Because no stack trace is displayed, it is not possible to judge what happened at first glance.
* As a workaround, we are considering replacing it with a network library that can handle synchronization other than URLSession. On Linux, URLSession is not very good because correspondence of HTTPS is also insufficient.🐷

