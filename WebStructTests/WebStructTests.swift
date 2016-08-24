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
    
        let test = try? Structer<DummyStruct,ApplicationError>().get( TestParam(param: "hoge") )
        
        XCTAssert(test != nil,"test is nil.")
        //XCTAssert(test! is DummyStruct,"test is not DummyStruct.")
    }
    
    func testInitalizeError(){
        do{
            let _ = try Structer<ErrorStruct,ApplicationError>().get( TestParam(param: "hoge") )
        }catch let error as WebStruct.Error{
            if case .application(let e) = error{
                XCTAssert( e is ApplicationError, "Error serialize fail.")
                return
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
