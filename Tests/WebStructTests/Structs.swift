//
//  Structs.swift
//  WebStruct
//
//  Created by iq3 on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

@testable import WebStruct

// Body struct
public struct RequestStruct : Encodable{
    let value:String
}
extension RequestStruct : WebDeserializable {
}


// Error type
public struct ApplicationError : Swift.Error, Decodable{
    let code:Int
    let reason:String
}
extension ApplicationError : WebSerializable{
}


// Basic pattern
public struct BasicStruct : Decodable{
    let message:String
}
extension BasicStruct : WebInitializable {
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
}


// Abnormal pattern
public struct ErrorStruct : Decodable{
    
}
extension ErrorStruct : WebInitializable{
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
}


// Added custom request
public struct CustomRequestStruct : Decodable{
    
}
extension CustomRequestStruct : WebInitializable {
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
    
    public static var request:URLRequest {
        guard let url = URL(string: "http://" ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:1.0 )
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        return request
    }
}


// Added custom Session
public struct CustomSessionStruct : Decodable{
}
extension CustomSessionStruct : WebInitializable {
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
    
    public static var session:URLSession {
        let def = URLSessionConfiguration.default
        def.allowsCellularAccess = false
        return URLSession(configuration: def, delegate: nil, delegateQueue: nil)
    }
}


// Added custom http header
public struct CustomHeadersStruct : Decodable{
    let headers:[String:String]
}
extension CustomHeadersStruct : WebInitializable {
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
    
    public static var request:URLRequest {
        guard let url = URL(string: "http://" ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:3.0 )
        request.httpMethod = "OPTIONS"
        
        let headers = [
            "Content-Type" : "application/json",
            "HeaderForTest" : "ValueForTest"
        ]
        for (key,value) in headers{
            request.addValue( value, forHTTPHeaderField:key)
        }
        
        return request
    }
}


