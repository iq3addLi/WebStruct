//
//  Structs.swift
//  WebStruct
//
//  Created by Arakane Ikumi on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

@testable import WebStruct

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

// Abnormal pattern
struct ErrorStruct {
    
}

extension ErrorStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError

    static var path = "http://localhost:8080/error"
    
    init (fromJson json:Any) throws{
        // error intentionally
        throw ParseError(code: 0, reason: "")
    }
}


// Added custom property
struct CustomStruct {
    
}

extension CustomStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError
    
    static var path = "http://localhost:8080/timeout"
    
    static var timeout = 3
    static var configuration:URLSessionConfiguration {
        let def = URLSessionConfiguration.default
        def.allowsCellularAccess = false
        return def
    }
    
    init (fromJson json:Any) throws{
        
    }
}


// Added custom http header
struct CustomHeadersStruct {
    let headers:[String:String]
}

extension CustomHeadersStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError
    
    static var path  = "http://localhost:8080/headers"
    static var method = "OPTIONS"
    static var headers = [
        "hello" : "world"
    ]
    
    init (fromJson json:Any) throws{
        
        guard case let dic as [String:Any] = json
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let headers as [String:String] = dic["YourHTTPHeader"]
            else { throw ParseError(code: -1, reason: "YourHTTPHeader is not found.") }
        
        self.headers = headers
    }
}


// Posting value
struct TestParam {
    let param:String
}

extension TestParam : WebDeserializable {
    func toJsonData() -> Any{
        return [ "param" : param ]
    }
}


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
