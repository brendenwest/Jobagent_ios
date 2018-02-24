//
//  Event.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import Foundation
import CoreData

class Event: NSManagedObject {
    
    @NSManaged var title: String?
    @NSManaged var date: Date?
    @NSManaged var type: String?
    @NSManaged var priority: String?
    @NSManaged var notes: String?
    
    @NSManaged var company: Company?
    @NSManaged var contact: Person?
    @NSManaged var job: Job?
    
    func valueFor(field: ModelFieldType) -> Any {
        switch field {
        case .date: return date as Any
        default:
            return stringValueFor(field:field)
        }
    }
    
    func stringValueFor(field: ModelFieldType) -> String {
        switch field {
        case .title: return title ?? ""
        case .date:
            guard let date = date else { return "-" }
            return DateUtilities.dateStringFrom(date: date, format: .short)
        case .type: return type ?? ""
        case .priority: return priority ?? ""
        case .notes: return notes ?? ""
        case .company: return company?.name ?? ""
        case .contact: return contact?.getFullName() ?? ""
        case .job: return job?.title ?? ""
        default: return ""
        }
    }
    
    func setValue(value: Any, forField field: ModelFieldType) {
        switch field {
        case .title: if let title = value as? String { self.title = title }
        case .date:
            if let date = value as? Date { self.date = date }
            else if let swString = value as? String, let swFromString = DateUtilities.dateFrom(string: swString, format: .short) { self.date = swFromString }
        case .type: if let type = value as? String { self.type = type }
        case .priority: if let priority = value as? String { self.priority = priority }
        case .notes: if let notes = value as? String { self.notes = notes }
        case .company: if let company = value as? String { DataController.setCompany(name: company, for: self) }
        case .contact: if let contact = value as? String { DataController.setPerson(name: contact, for: self) }
        //        case .job: if let job = value as? String { DataController.setJob(title: job, for: self) }
        default:
            break
        }
    }
    
}
