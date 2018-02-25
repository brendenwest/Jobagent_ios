//
//  Person.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import Foundation
import CoreData

class Person: NSManagedObject {
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var notes: String?
    @NSManaged var phone: String?
    @NSManaged var email: String?
    @NSManaged var company: Company?
    @NSManaged var job: Job?
    
    func stringValueFor(field: ModelFieldType) -> String {
        switch field {
        case .name: return self.getFullName()
        case .title: return title ?? ""
        case .company: return company?.name ?? ""
        case .job: return job?.title ?? ""
        case .type: return type ?? ""
        case .notes: return notes ?? ""
        case .phone: return phone ?? ""
        case .email: return email ?? ""
        default: return ""
        }
    }
    
    func setValue(value: Any, forField field: ModelFieldType) {
        switch field {
        case .name: if let person = Person.getNameParts(value as? String) {
            self.firstName = person.firstName
            self.lastName = person.lastName
            }
        case .title: if let title = value as? String { self.title = title }
        case .type: if let type = value as? String { self.type = type }
        case .notes: if let notes = value as? String { self.notes = notes }
        case .company: if let company = value as? String { DataController.setCompany(name: company, for: self) }
        //        case .job: if let job = value as? String { DataController.setJob(name: Job, for: self) }
        case .phone: if let phone = value as? String { self.phone = phone }
        case .email: if let email = value as? String { self.email = email }
        default:
            break
        }
    }
    
    func getFullName() -> String {
        
        let first = self.firstName ?? ""
        let last = self.lastName ?? ""
        let separator = !first.isEmpty && !last.isEmpty ? " " : ""
        
        return "\(first)\(separator)\(last)"
        
    }
    
    // add new company item if not exists
    func setCompany(name: String?) {
        DataController.setCompany(name: name, for: self)
    }
    
    static func getNameParts(_ name: String?) -> (firstName: String, lastName: String)? {
        if let name = name {
            let nameArray = name.components(separatedBy: " ")
            let first = nameArray[0]
            let last = nameArray.count > 1 ? nameArray[1] : ""
            return (first, last)
        }
        
        return nil // input string was empty
    }
    
}
