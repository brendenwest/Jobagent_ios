//
//  CoreDataTestCase.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import XCTest
import CoreData

@testable import jobagent

class CoreDataTestCase:XCTestCase {
    
    lazy var managedObjectContext = DataController(completionClosure: {}).container.viewContext
    
    override func setUp() {
        
    }
    
    override func tearDown() {
//        managedObjectContext = nil
    }
}
