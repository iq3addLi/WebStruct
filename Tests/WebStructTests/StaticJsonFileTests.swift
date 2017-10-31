//
//  StaticJsonFileTests.swift
//  WebStruct
//
//  Created by iq3AddLi on 2017/09/04.
//
//

import Foundation

import XCTest
@testable import WebStruct


class StaticJsonFileTests: XCTestCase {
    
    static let allTests = [
        ("testGetJSONFile", testGetJSONFile),
        //("testItunesSearchTimeout",testItunesSearchTimeout) // did'nt timeout in Linux
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetJSONFile() {
        let file:[Place]
        do{ file = try [Place](path: "http://motorhomes.addli.jp/assets/json/places.json") }catch{
            print(error)
            fatalError()
        }
        XCTAssertEqual( file.count, 4 )
    }
}

struct Place : Decodable{
    let title:String
    let type:String
    let postalCode:String
    let address:String
    let tel:String
    let url:URL
    let location:[String:Double]
}

extension Array : WebInitializable{
    public typealias bodyType = RequestStruct
    public typealias errorType = ApplicationError
}

