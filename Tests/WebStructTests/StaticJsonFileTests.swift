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
        guard let file = try? PlacesFile(
            "http://motorhomes.addli.jp/assets/json/places.json"
            ) else { fatalError() }
        XCTAssertEqual( file.places.count, 4 )
    }
}


struct Place{
    let title:String
}

struct PlacesFile{
    let places:[Place]
}

extension PlacesFile : WebInitializable {
    typealias inputType = RequestStruct
    typealias errorType = ApplicationError
    
    init (fromObject object:Any) throws{
        
        guard case let array as [[String:Any]] = object
            else { throw ParseError(code: -1, reason: "Return body is not array.") }
        
        self.places = try array.map({ place in
            guard case let title as String = place["title"]
                else{ throw ParseError(code: -1, reason: "The title not contain.") }
            return Place( title: title )
        })
    }
}
