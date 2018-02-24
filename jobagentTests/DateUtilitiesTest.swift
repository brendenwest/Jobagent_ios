//
//  DateUtilitiesTest.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import XCTest

@testable import jobagent

class DateUtilitiesTest: XCTestCase {

    let dateStringLong = "2017-06-01T01:01:00.000Z"
    let dateStringShort = "06/01/2017"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateFromString() {
        let date = DateUtilities.dateFrom(string: dateStringLong, format: .long)
        XCTAssertEqual(DateUtilities.dateStringFrom(date: date!, format: .short), dateStringShort, "date conversion failed")
    }

    func testLongToShortDateString() {
        let str = DateUtilities.dateStringFrom(string: dateStringLong)
        XCTAssertEqual(str, dateStringShort, "date conversion failed")        
    }

    
}
