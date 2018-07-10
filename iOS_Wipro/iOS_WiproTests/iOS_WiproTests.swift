//
//  iOS_WiproTests.swift
//  iOS_WiproTests
//
//  Created by SierraVista Technologies Pvt Ltd on 09/07/18.
//  Copyright © 2018 Shital. All rights reserved.
//

import XCTest
@testable import iOS_Wipro

class iOS_WiproTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testUserData() {
        guard let gitUrl = URL(string: "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json") else { return }
        let promise = expectation(description: "Simple Request")
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            
            if let responseString = String(data: data, encoding: String.Encoding.ascii) {
                
                if let jsonData = responseString.data(using: String.Encoding.utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
                        
                        if (json[Constants.GlobalConstants.rowsKey] as? [[String: AnyObject]]) != nil {
                            XCTAssertTrue(json[Constants.GlobalConstants.titleKey] as! String != "")
                            promise.fulfill()
                        }
                        
                    } catch {
                        print("Err", error)
                    }
                }
            }
            }.resume()
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testUserDataFailCase() {
        guard let gitUrl = URL(string: Constants.GlobalConstants.apiURL) else { return }
        let promise = expectation(description: "Simple Request")
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let result = json as? NSDictionary {
                    XCTAssertTrue(result[Constants.GlobalConstants.titleKey] as! String != "")
                    promise.fulfill()
                }
            } catch let err {
                print("Err", err)
            }
            }.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
}
