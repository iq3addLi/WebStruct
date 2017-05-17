//
//  WebStructTests.swift
//  WebStructTests
//
//  Created by iq3 on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import XCTest
@testable import WebStruct

/**
 This UnitTest is need WebStrcutTestServer(https://github.com/iq3addLi/WebStructTestServer.git) running.
 */
class WebStructTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBasicInitalize() {
        let basic = try? BasicStruct( RequestStruct(value: "hello") )
        XCTAssert(basic != nil,"test is nil.")
    }
    
    func testInitalizeError(){
        do{
            let _ = try ErrorStruct( RequestStruct(value: "hello") )
        }
        catch let error as WebStruct.Error{
            switch (error) {
            case .network(let _):
                // Network error
                XCTAssert( false,"Unexpected error.")
            case .http(let _):
                // HTTP error
                XCTAssert( false,"Unexpected error.")
            case .ignoreData:
                // Unexpected response data
                XCTAssert( false,"Unexpected error.")
            case .parse(let _):
                // Failed parse response data
                XCTAssert( false,"Unexpected error.")
            case .application(let e):
                // Server side defined error
                XCTAssert( e is ApplicationError, "ApplicationError serialize is fail")
            }
        }
        catch {
            // Unexpected throws
            XCTAssert( false,"Unexpected error.")
        }
    }
    
    func testCustomProperty(){
        do{
            let _ = try CustomRequestStruct( RequestStruct(value: "hello") )
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
    
    func testCustomHttpHeaders(){
        let st:CustomHeadersStruct
        do{
            st = try CustomHeadersStruct( RequestStruct(value: "hello") )
        }
        catch let error as WebStruct.Error{
            XCTAssert(false,"Test failed. detail=\(error)");return
        }
        catch {
            XCTAssert(false,"Test failed.");return
        }
        
        XCTAssertEqual( st.headers["hello"] , "world" )
    }
}
