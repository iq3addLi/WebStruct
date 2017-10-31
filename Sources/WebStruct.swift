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
extension Error : CustomStringConvertible{
    public var description: String {
        get{
            switch self{
            case let .network(error):
                return "Network error. detail=\(error)"
            case let .http(error):
                return "HTTP error. detail=\(error)"
            case .ignoreData:
                return "Received ignore data."
            case let .parse(error):
                return "Parse failed on received data. detail=\(error)"
            case let .application(receivedError):
                return "Server defined error. body=\(receivedError)"
            }
        }
    }
}


/**
    Serializeable protocol
 */
public protocol WebSerializable{
    // Optional
    static func serialize(data:Data) throws -> Self
}
extension WebSerializable where Self : Decodable{
    public static func serialize(data:Data) throws -> Self {
        let serialized = try JSONDecoder().decode(Self.self, from: data)
        return serialized
    }
}


/**
    Deserializeable protocol
 */
public protocol WebDeserializable{
    // Optional
    func deserialize() throws -> Data
}
extension WebDeserializable where Self : Encodable{
    // default implements
    public func deserialize() throws -> Data {
        let deserialized: Data = try JSONEncoder().encode(self)
        return deserialized
    }
}


/**
    Initializable protocol
 */
public protocol WebInitializable : WebSerializable {
    associatedtype bodyType: WebDeserializable
    associatedtype errorType: WebSerializable
    
    // Optional
    static var request:URLRequest { get }
    static var session:URLSession { get }
}
/**
  Default implement for WebInitializable
 */
extension WebInitializable{
    public init(_ path:String, body:Self.bodyType? = nil) throws {
        self = try WebStruct<Self,Self.errorType>().get( path, body: body)
    }

    // default values
    public static var request:URLRequest {
        let request = URLRequest(url:URL(string:"http://")!, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:5.0 )
        return request
    }
    
    public static var session:URLSession {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    }
    
}


/**
   WebStruct
 */
fileprivate struct WebStruct <GenT:WebInitializable,ErrorT:WebSerializable>{
    
    fileprivate init(){}
    
    fileprivate func get<BodyT:WebDeserializable>(_ path:String, body:BodyT?) throws -> GenT {
        
        // setup for request
        var request = GenT.request
        
        guard let url = URL(string: path ) else{ print("Path is not URL."); fatalError() }
        request.url = url
        
        if let body = body {
            // verify for request
            let someBody: Data
            do { someBody = try body.deserialize() } catch { print(error); throw error }
            request.httpBody = someBody
            if let method = request.httpMethod,
                method == "GET" { request.httpMethod = "POST" }
            if request.value(forHTTPHeaderField: "Content-Type") == .none {
                request.addValue("application/json", forHTTPHeaderField:"Content-Type")
            }
        }
        
        // send request
        let session = GenT.session
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
            default:
                throw Error.http(
                    NSError(domain: "HTTPError",
                            code: httpResponse.statusCode,
                            userInfo: [
                                "description" : HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        ])
                )
            }
        }
        
        // parse
        guard let someData = data else{
            throw Error.ignoreData
        }
        let newStruct:GenT
        do{
            newStruct = try GenT.serialize(data: someData)
        }
        catch(let serializeError){
            let appError:ErrorT
            do { appError = try ErrorT.serialize(data: someData)} catch{
                throw Error.parse(serializeError)
            }
            throw Error.application(appError)
        }
        
        // complete
        return newStruct
    }
}


