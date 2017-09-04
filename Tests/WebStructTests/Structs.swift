//
//  Structs.swift
//  WebStruct
//
//  Created by iq3 on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

@testable import WebStruct

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

// Abnormal pattern
struct ErrorStruct {
    
}

extension ErrorStruct : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    init (fromObject object:Any) throws{
        // error intentionally
        throw ParseError(code: 0, reason: "")
    }
}


// Added custom request
struct CustomRequestStruct {
    
}

extension CustomRequestStruct : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    static var request:URLRequest {
        guard let url = URL(string: "http://" ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:1.0 )
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        return request
    }
    
    init (fromObject object:Any) throws{
        
    }
}

// Added custom Session
struct CustomSessionStruct {
    
}

extension CustomSessionStruct : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    static var session:URLSession {
        let def = URLSessionConfiguration.default
        def.allowsCellularAccess = false
        return URLSession(configuration: def, delegate: nil, delegateQueue: nil)
    }
    
    init (fromObject object:Any) throws{
        
    }
}


// Added custom http header
struct CustomHeadersStruct {
    let headers:[String:String]
}

extension CustomHeadersStruct : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    static var request:URLRequest {
        guard let url = URL(string: "http://" ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:3.0 )
        request.httpMethod = "OPTIONS"
        
        let headers = [
            "Content-Type" : "application/json",
            "hello" : "world"
        ]
        for (key,value) in headers{
            request.addValue( value, forHTTPHeaderField:key)
        }
        
        return request
    }
    
    init (fromObject object:Any) throws{
        
        guard case let dic as [String:Any] = object
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let headers as [String:String] = dic["YourHTTPHeader"]
            else { throw ParseError(code: -1, reason: "YourHTTPHeader is not found.") }
        
        self.headers = headers
    }
}

// Posting value
struct RequestStruct {
    let value:String
}

extension RequestStruct : WebDeserializable {
    func toObject() -> Any{
        return [ "key" : value ]
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
