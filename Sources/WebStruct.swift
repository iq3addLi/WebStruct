//
//  WebStruct.swift
//  WebStruct
//
//  Created by Arakane Ikumi on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation
import Dispatch

public indirect enum Error : Swift.Error{
    case network(Swift.Error)
    case http(Swift.Error)
    case ignoreData
    case parse(Swift.Error)
    case application(WebSerializable)
}

public protocol WebSerializable{
    init (fromJson:Any) throws
}

public protocol WebInitializable : WebSerializable {
    associatedtype inputType: WebDeserializable
    associatedtype errorType: WebSerializable
    
    static var timeout:TimeInterval { get }
    static var path:String { get }
}

extension WebInitializable{
    static public func get(_ param:Self.inputType) throws -> Self{
        return try Structer<Self,Self.errorType>().get( param )
    }
    static public var timeout:TimeInterval { return 5.0 }
}

public protocol WebDeserializable {
    func toJsonData() -> Any
}


public struct Structer <T:WebInitializable,ERR:WebSerializable>{
    
    public init(){}
    
    public func get<P:WebDeserializable>(_ param:P) throws -> T {
        
        guard let url = URL(string: T.path )
            else{ fatalError() }
        
        guard let body = try? JSONSerialization.data(withJSONObject: param.toJsonData(), options: JSONSerialization.WritingOptions())
            else{ fatalError() }
        
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:T.timeout)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = body
        
        #if os(macOS) || os(iOS)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: URLSessionDelegateClass(), delegateQueue: nil)
        #else
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate:nil, delegateQueue: nil)
        #endif
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var data:Data?,response:URLResponse?,error:Swift.Error?
        let subtask = session.dataTask(with: request) { (d, r, e) in
            data = d; response = r; error = e;
            semaphore.signal()
        }
        subtask.resume()
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let error = error {
            throw Error.network(error)
        }
        
        if case let httpResponse as HTTPURLResponse = response{
            switch httpResponse.statusCode{
            case 200...299: break
            default: throw Error.http(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            }
        }
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
        
        return gen
    }
}


// 自己証明書回避
#if os(macOS) || os(iOS)
class URLSessionDelegateClass : NSObject, URLSessionDelegate{
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        

        var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            disposition = .useCredential
            credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        } else {
            if challenge.previousFailureCount > 0 {
                disposition = .cancelAuthenticationChallenge
            } else {
                credential = session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                
                if credential != nil {
                    disposition = .useCredential
                }
            }
        }
        completionHandler(disposition, credential)
    }
}

#else

extension URLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}

#endif

