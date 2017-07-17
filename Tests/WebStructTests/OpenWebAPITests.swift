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
        //("testItunesSearchTimeout",testItunesSearchTimeout) // did'nt timeout in Linux
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

