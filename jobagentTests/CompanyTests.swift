//
//  CompanyTests.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import XCTest
import CoreData

@testable import jobagent

class CompanyTests: CoreDataTestCase {

    var company:Company?
    
    override func setUp() {
        super.setUp()
        company = Company(context: managedObjectContext)
    }
    
    func testCreateCompany() {
        XCTAssertNotNil(self.company, "unable to create a company")
    }

    func testSetName() {
        company?.setValue(value: "ACME", forField: .name)
        XCTAssertEqual(company?.name, "ACME", "unable to set name")
    }
}
