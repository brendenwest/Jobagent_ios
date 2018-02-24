//
//  Company.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import Foundation
import CoreData

class Company: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var location: String?
    @NSManaged var notes: String?
    @NSManaged var jobs: Set<Job>?
    @NSManaged var people: Set<Person>?
    @NSManaged var toEvent: Set<Event>?
        
    @objc(addPeopleObject:)
    @NSManaged public func addToPeople(_ value: Person)
    
    @objc(removePeopleObject:)
    @NSManaged public func removeFromPeople(_ value: Person)
    
    @objc(addPeople:)
    @NSManaged public func addToPeople(_ values: NSSet)
    
    @objc(removePeople:)
    @NSManaged public func removeFromPeople(_ values: NSSet)
    
    @objc(addJobsObject:)
    @NSManaged public func addToJobs(_ value: Job)
    
    @objc(removeJobsObject:)
    @NSManaged public func removeFromJobs(_ value: Job)
    
    @objc(addJobs:)
    @NSManaged public func addToJobs(_ values: NSSet)
    
    @objc(removeJobs:)
    @NSManaged public func removeFromJobs(_ values: NSSet)
    
    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)
    
    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    func stringValueFor(field: ModelFieldType) -> String {
        switch field {
        case .name: return name ?? ""
        case .location: return location ?? ""
        case .type: return type ?? ""
        case .notes: return notes ?? ""
        default: return ""
        }
    }
    
    func setValue(value: Any, forField field: ModelFieldType) {
        switch field {
        case .name: if let name = value as? String { self.name = name }
        case .location: if let location = value as? String { self.location = location }
        case .type: if let type = value as? String { self.type = type }
        case .notes: if let notes = value as? String { self.notes = notes }
        default:
            break
        }
    }
}
