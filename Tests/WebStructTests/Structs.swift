//
//  Structs.swift
//  WebStruct
//
//  Created by iq3 on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

@testable import WebStruct

// Posting value
public struct RequestStruct {
    let value:String
}

extension RequestStruct : WebDeserializable {
    public func toObject() -> Any{
        return [ "key" : value ]
    }
}


// Error type
public struct ParseError : Swift.Error{
    let code:Int
    let reason:String
}

public struct ApplicationError : Swift.Error{
    let code:Int
    let reason:String
}


extension ApplicationError : WebSerializable{
    public init (fromObject object:Any) throws{
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


// Basic pattern
public struct BasicStruct {
    let message:String
}

extension BasicStruct : WebInitializable {
    public typealias inputType = RequestStruct
    public typealias errorType = ApplicationError
    
    public init (fromObject object:Any) throws{
        guard case let dic as [String:Any] = object
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let message as String = dic["message"]
            else { throw ParseError(code: -1, reason: "Message is not found.") }
        
        self.message = message
    }
}

// Abnormal pattern
public struct ErrorStruct {
    
}

extension ErrorStruct : WebInitializable {
    public typealias inputType = RequestStruct
    public typealias errorType = ApplicationError
    
    public init (fromObject object:Any) throws{
        // error intentionally
        throw ParseError(code: 0, reason: "")
    }
}


// Added custom request
public struct CustomRequestStruct {
    
}

extension CustomRequestStruct : WebInitializable {
    public typealias inputType = RequestStruct
    public typealias errorType = ApplicationError
    
    public static var request:URLRequest {
        guard let url = URL(string: "http://" ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:1.0 )
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        return request
    }
    
    public init (fromObject object:Any) throws{
    }
}

// Added custom Session
public struct CustomSessionStruct {
    
}

extension CustomSessionStruct : WebInitializable {
    public typealias inputType = RequestStruct
    public typealias errorType = ApplicationError
    
    public static var session:URLSession {
        let def = URLSessionConfiguration.default
        def.allowsCellularAccess = false
        return URLSession(configuration: def, delegate: nil, delegateQueue: nil)
    }
    
    public init (fromObject object:Any) throws{
        
    }
}


// Added custom http header
public struct CustomHeadersStruct {
    let headers:[String:String]
}

extension CustomHeadersStruct : WebInitializable {
    public typealias inputType = RequestStruct
    public typealias errorType = ApplicationError
    
    public static var request:URLRequest {
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
    
    public init (fromObject object:Any) throws{
        
        guard case let dic as [String:Any] = object
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let headers as [String:String] = dic["YourHTTPHeader"]
            else { throw ParseError(code: -1, reason: "YourHTTPHeader is not found.") }
        
        self.headers = headers
    }
}


