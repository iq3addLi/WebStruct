//
//  Structs.swift
//  WebStruct
//
//  Created by Arakane Ikumi on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

@testable import WebStruct

struct TestParam {
    let param:String
}

extension TestParam : WebDeserializable {
    func toJsonData() -> AnyObject{
        return [ "param" : param ]
    }
}

struct DummyStruct {
    let message:String
}

extension DummyStruct : WebInitializable {
    
    static func path() -> String {
        return "http://localhost:8080/dummy"
    }
    
    init (fromJson:AnyObject) throws{
        guard case let json as [String:AnyObject] = fromJson
            else { throw Error(code: -1, reason: "not dictionary") }
        
        guard case let message as String = json["message"]
            else { throw Error(code: -1, reason: "message not found.") }
        
        self.message = message
    }
}

struct ErrorStruct {
    
}

extension ErrorStruct : WebInitializable {
    
    static func path() -> String {
        return "http://localhost:8080/error"
    }
    
    init (fromJson:AnyObject) throws{
        // error intentionally
        throw Error(code: 0, reason: "")
    }
}


struct Error : ErrorType{
    let code:Int
    let reason:String
}

struct ApplicationError : ErrorType{
    let code:Int
    let reason:String
}

extension ApplicationError : WebSerializable{
    init (fromJson:AnyObject) throws{
        guard case let dic as [String:AnyObject] = fromJson
            else{ throw NSError(domain: "", code: 0, userInfo: nil) }
        
        guard case let error as [String:AnyObject] = dic["error"]
            else{ throw NSError(domain: "", code: 0, userInfo: nil) }
        
        guard case let code as Int = error["code"]
            else{ throw NSError(domain: "", code: 0, userInfo: nil)  }
        self.code = code
        
        guard case let reason as String = error["reason"]
            else{ throw NSError(domain: "", code: 0, userInfo: nil)  }
        self.reason = reason
    }
}
