//
//  OpenWebAPITests.swift
//  WebStruct
//
//  Created by iq3 on 2017/05/17.
//
//

import Foundation

import XCTest
@testable import WebStruct

class OpenWebAPITests: XCTestCase {
    
    static let allTests = [
        ("testItunesSearch", testItunesSearch),
        ("testItunesSearchTimeout",testItunesSearchTimeout)
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testItunesSearch() {
        guard let search = try? iTunesSearch( RequestStruct(value: "hello") ) else { fatalError() }
        XCTAssertEqual( search.resultCount, 10 )
    }
    
    func testItunesSearchTimeout() {
        do{
            let _ = try iTunesTimeoutSearch( RequestStruct(value: "hello") )
        }
        catch let error as WebStruct.Error{
            if case .network(let e) = error{
                if case let nserror as NSError = e,
                    nserror.userInfo["NSLocalizedDescription"] as! String == "The request timed out."{
                    return // OK
                }
            }
        }
        catch { }
        
        XCTAssert(false,"invalid error.")
    }
}


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
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:0.0001 )
        request.httpMethod = "GET"
        return request
    }
    
    init (fromObject object:Any) throws{
        
    }
}
