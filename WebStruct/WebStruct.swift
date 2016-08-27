//
//  WebStruct.swift
//  WebStruct
//
//  Created by Arakane Ikumi on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import Foundation

public enum Error : ErrorType{
    case network(ErrorType)
    case http(ErrorType)
    case ignoreData
    case parse(ErrorType)
    case application(WebSerializable)
}

public protocol WebSerializable{
    init (fromJson:AnyObject) throws
}

public protocol WebInitializable : WebSerializable {
    static func path() -> String
}

public protocol WebDeserializable {
    func toJsonData() -> AnyObject
}


public struct Structer <T:WebInitializable,ERR:WebSerializable>{
    
    public init(){}
    
    public func get<P:WebDeserializable>(param:P) throws -> T {
        
        guard let url = NSURL(string: T.path() )
            else{ fatalError() }
        
        guard let body = try? NSJSONSerialization.dataWithJSONObject(param.toJsonData(), options: NSJSONWritingOptions())
            else{ fatalError() }
        
        let request = NSMutableURLRequest(URL:url, cachePolicy:.ReloadIgnoringLocalCacheData, timeoutInterval:3.0)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.HTTPBody = body
        
        var data:NSData?
        var response:NSURLResponse?
        var error:NSError?
        
        let semaphore = dispatch_semaphore_create(0)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: NSURLSessionDelegateClass(), delegateQueue: nil)
        let subtask = session.dataTaskWithRequest( request ) { d,r,e in
            data = d; response = r; error = e;
            dispatch_semaphore_signal(semaphore)
        }
        subtask.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        if let error = error {
            throw Error.network(error)
        }
        
        if case let httpResponse as NSHTTPURLResponse = response{
            switch httpResponse.statusCode{
            case 200...299: break
            default: throw Error.http(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            }
        }
        guard let someData = data
            else { throw Error.ignoreData }
        guard let jsonDic = try? NSJSONSerialization.JSONObjectWithData(someData, options:NSJSONReadingOptions())
            else { throw Error.ignoreData }
        
        let gen:T
        do{
            gen = try T(fromJson:jsonDic )
        }
        catch{
            guard let err = try? ERR( fromJson:jsonDic )
                else{ throw Error.parse(error) }
            
            throw Error.application(err)
        }
        
        return gen
    }
}

// 自己証明書回避
class NSURLSessionDelegateClass : NSObject, NSURLSessionDelegate{
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void){
        
        var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
        var credential: NSURLCredential?
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            disposition = NSURLSessionAuthChallengeDisposition.UseCredential
            credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
        } else {
            if challenge.previousFailureCount > 0 {
                disposition = .CancelAuthenticationChallenge
            } else {
                credential = session.configuration.URLCredentialStorage?.defaultCredentialForProtectionSpace(challenge.protectionSpace)
                
                if credential != nil {
                    disposition = .UseCredential
                }
            }
        }
        
        completionHandler(disposition, credential)
    }
}