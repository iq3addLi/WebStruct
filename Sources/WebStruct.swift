//
//  WebStruct.swift
//  WebStruct
//
//  Created by iq3 on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation
import Dispatch

/**
    WebStruct error type
 */
public indirect enum Error : Swift.Error{
    case network(Swift.Error)
    case http(Swift.Error)
    case ignoreData
    case parse(Swift.Error)
    case application(WebSerializable)
}

/**
    Json serializeable protocol
 */
public protocol WebSerializable{
    // Must implement
    init (fromJson json:Any) throws
}

/**
    Json deserializeable protocol
 */
public protocol WebDeserializable {
    // Must implement
    func toJsonData() -> Any
}

/**
    Json initializable protocol
 */
public protocol WebInitializable : WebSerializable {
    associatedtype inputType: WebDeserializable
    associatedtype errorType: WebSerializable
    
    // Must implement
    static var path:String { get }
    
    // Optional
    static var method:String { get }
    static var headers:[String:String] { get }
    static var timeout:TimeInterval { get }
    static var configuration:URLSessionConfiguration { get }
    static var urlsessionDelegate:URLSessionDelegate? { get }
}

/**
  Default implement for WebInitializable
 */
extension WebInitializable{
    public init(_ param:Self.inputType) throws {
        self = try WebStruct<Self,Self.errorType>().get( param )
    }

    // default values
    static public var method:String { return "POST" }
    static public var headers:[String:String] { return [:] }
    static public var timeout:TimeInterval { return 5.0 }
    static public var configuration:URLSessionConfiguration { return URLSessionConfiguration.default }
    static public var urlsessionDelegate:URLSessionDelegate? { return nil }
}

/**
   Default implement for WebInitializable
 */
fileprivate struct WebStruct <T:WebInitializable,ERR:WebSerializable>{
    
    fileprivate init(){}
    
    fileprivate func get<P:WebDeserializable>(_ param:P) throws -> T {
        
        // verify for request
        guard let url = URL(string: T.path ) else{ fatalError() }
        guard let body = try? JSONSerialization.data(withJSONObject: param.toJsonData(), options: JSONSerialization.WritingOptions()) else{ fatalError() }
        
        // setup for request
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:T.timeout)
        request.httpMethod = T.method
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        for (key,value) in T.headers {
            request.addValue( value, forHTTPHeaderField: key )
        }
        request.httpBody = body
        
        // send request
        let session = URLSession(configuration: T.configuration, delegate: T.urlsessionDelegate, delegateQueue: nil)
        let semaphore = DispatchSemaphore(value: 0)
        var data:Data?,response:URLResponse?,error:Swift.Error?
        let subtask = session.dataTask(with: request) { (d, r, e) in
            data = d; response = r; error = e;
            semaphore.signal()
        }
        subtask.resume()
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        // verify for response
        if let error = error {
            throw Error.network(error)
        }
        
        if case let httpResponse as HTTPURLResponse = response{
            switch httpResponse.statusCode{
            case 200...299: break
            default: throw Error.http(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [ "description" : HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode) ]) )
            }
        }
        
        // parse
        guard let someData = data,
            let jsonDic = try? JSONSerialization.jsonObject(with: someData, options:JSONSerialization.ReadingOptions())
            else { throw Error.ignoreData }
        
        let gen:T
        do{
            gen = try T( fromJson:jsonDic )
        }
        catch(let initError){
            guard let err = try? ERR( fromJson:jsonDic )
                else{ throw Error.parse(initError) }
            
            throw Error.application(err)
        }
        
        // complete
        return gen
    }
}


