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
    
    static var request:URLRequest {
        var request = URLRequest(url:URL(string:"http://")!,
                                 cachePolicy:.reloadIgnoringLocalCacheData,
                                 timeoutInterval:0.00001 )
        request.httpMethod = "GET"
        return request
    }
    
    init (fromObject object:Any) throws{
        
    }
}

