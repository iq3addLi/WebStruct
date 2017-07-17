//
//  Types.swift
//  WebStruct
//
//  Created by Arakane Ikumi on 2017/07/17.
//
//

import Foundation

@testable import WebStruct

// Basic pattern
struct iTunesSearch {
    let resultCount:Int
}

extension iTunesSearch : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    static var path = "https://itunes.apple.com/search?term=twitter&media=software&entity=software&limit=10"
    
    static var request:URLRequest {
        guard let url = URL(string: iTunesSearch.path ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:3.0 )
        request.httpMethod = "GET"
        return request
    }
    
    init (fromObject object:Any) throws{
        guard case let dic as [String:Any] = object
            else { throw ParseError(code: -1, reason: "Return body is not a dictionary.") }
        
        guard case let resultCount as Int = dic["resultCount"]
            else { throw ParseError(code: -1, reason: "resultCount is not found.") }
        
        self.resultCount = resultCount
    }
}



// Timeout pattern
struct iTunesTimeoutSearch {
}


extension iTunesTimeoutSearch : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    static var path = "https://itunes.apple.com/search?term=twitter&media=software&entity=software&limit=10"
    
    static var request:URLRequest {
        guard let url = URL(string: iTunesTimeoutSearch.path ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:0.00001 )
        request.httpMethod = "GET"
        return request
    }
    
    init (fromObject object:Any) throws{
        
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
