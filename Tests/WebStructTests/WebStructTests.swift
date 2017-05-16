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
        let basic = try? BasicStruct( TestParam(param: "hello") )
        XCTAssert(basic != nil,"test is nil.")
    }
    
    func testInitalizeError(){
        do{
            let _ = try ErrorStruct( TestParam(param: "hello") )
        }
        catch let error as WebStruct.Error{
            if case .application(let e) = error{
                XCTAssert( e is ApplicationError, "Error serialize fail.")
                return
            }
        }
        catch { }
        
        XCTAssert(false,"invalid error.")
    }
    
    func testCustomProperty(){
        do{
            let _ = try CustomStruct( TestParam(param: "hello") )
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
            st = try CustomHeadersStruct( TestParam( param: "hello") )
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
