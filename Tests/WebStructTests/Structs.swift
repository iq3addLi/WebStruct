//
//  Structs.swift
//  WebStruct
//
//  Created by Arakane Ikumi on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

@testable import WebStruct

struct DummyStruct {
    let message:String
}

extension DummyStruct : WebInitializable {
    typealias inputType = TestParam
    typealias errorType = ApplicationError

    static var path = "http://localhost:8080/dummy"
    
    init (fromJson json:Any) throws{
        guard case let dic as [String:Any] = json
            else { throw ParseError(code: -1, reason: "not dictionary") }
        
        guard case let message as String = dic["message"]
            else { throw ParseError(code: -1, reason: "message not found.") }
        
        self.message = message
    }
}

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


struct TestParam {
    let param:String
}

extension TestParam : WebDeserializable {
    func toJsonData() -> Any{
        return [ "param" : param ]
    }
}

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
