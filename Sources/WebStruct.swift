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
    Serializeable protocol
 */
public protocol WebSerializable{
    // Must implement
    init (fromObject object:Any) throws
    
    // Optional
    static func serialize(data:Data) throws -> Any
}

extension WebSerializable{
    // default implements
    static func serialize(data:Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions())
    }
}

/**
    Deserializeable protocol
 */
public protocol WebDeserializable {
    // Must implement
    func toObject() -> Any
    
    // Optional
    func deserialize() throws -> Data
}

extension WebDeserializable{
    // default implements
    func deserialize() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self.toObject(), options: JSONSerialization.WritingOptions())
    }
}

/**
    Initializable protocol
 */
public protocol WebInitializable : WebSerializable {
    associatedtype inputType: WebDeserializable
    associatedtype errorType: WebSerializable
    
    // Must implement
    static var path:String { get }
    
    // Optional
    static var request:URLRequest { get }
    static var session:URLSession { get }
}

/**
  Default implement for WebInitializable
 */
extension WebInitializable{
    public init(_ param:Self.inputType) throws {
        self = try WebStruct<Self,Self.errorType>().get( param )
    }

    // default values
    static public var request:URLRequest {
        guard let url = URL(string: Self.path ) else{ fatalError() }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:5.0 )
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        return request
    }
    
    static public var session:URLSession {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    }
}

/**
   Default implement for WebInitializable
 */
fileprivate struct WebStruct <T:WebInitializable,ERR:WebSerializable>{
    
    fileprivate init(){}
    
    fileprivate func get<P:WebDeserializable>(_ param:P) throws -> T {
        
        // verify for request
        guard let body = try? param.deserialize() else{ fatalError() }
        
        // setup for request
        var request = T.request
        request.httpBody = body
        
        // send request
        let session = T.session
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
        guard let someData = data, let object = try? T.serialize( data:someData )
            else { throw Error.ignoreData }
        
        let newStruct:T
        do{
            newStruct = try T( fromObject:object )
        }
        catch(let error){
            guard let appError = try? ERR( fromObject:object ) else{ throw Error.parse(error) }
            throw Error.application(appError)
        }
        
        // complete
        return newStruct
    }
}


