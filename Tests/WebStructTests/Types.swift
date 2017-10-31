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
struct iTunesSearch : Decodable{
    let resultCount:Int
}
extension iTunesSearch : WebInitializable {
    typealias bodyType = RequestStruct
    typealias errorType = ApplicationError
}


// Timeout pattern
struct iTunesTimeoutSearch : Decodable{
}
extension iTunesTimeoutSearch : WebInitializable {

    typealias bodyType = RequestStruct
    typealias errorType = ApplicationError
    
    static var request:URLRequest {
        var request = URLRequest(url:URL(string:"http://")!,
                                 cachePolicy:.reloadIgnoringLocalCacheData,
                                 timeoutInterval:0.00001 )
        request.httpMethod = "GET"
        return request
    }
}

