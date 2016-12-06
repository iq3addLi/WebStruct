//
//  WebStructTests.swift
//  WebStructTests
//
//  Created by Arakane Ikumi on 2016/08/24.
//  Copyright © 2016年 addli.co.jp. All rights reserved.
//

import XCTest
@testable import WebStruct

class WebStructTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitalize() {
    
        let dummy = try? DummyStruct.get( TestParam(param: "hoge") )
        
        XCTAssert(dummy != nil,"test is nil.")
        //XCTAssert(test! is DummyStruct,"test is not DummyStruct.")
    }
    
    func testInitalizeError(){
        do{
            let _ = try ErrorStruct.get( TestParam(param: "hoge") )
        }catch let error as WebStruct.Error{
            if case .application(let e) = error{
                XCTAssert( e is ApplicationError, "Error serialize fail.")
                return
            }
        }
        catch { }
        
        XCTAssert(false,"invalid error.")
    }
    
    func testCustomize(){
        do{
            let _ = try CustomStruct.get( TestParam(param: "hoge") )
        }catch let error as WebStruct.Error{
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
//    func testPerformanceExample() {
//        self.measureBlock {
//        }
//    }
    
}
