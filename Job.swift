//
//  Job.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import Foundation
import CoreData

class Job: NSManagedObject {
    
    @NSManaged var title: String?
    @NSManaged var location: String?
    @NSManaged var link: String?
    @NSManaged var notes: String?
    @NSManaged var type: String?
    @NSManaged var pay: String?
    @NSManaged var date: Date?
    @NSManaged var company: Company?
    @NSManaged var contact: Person?
    
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
        case .location: return location ?? ""
        case .date:
            guard let date = date else { return "-" }
            return DateUtilities.dateStringFrom(date: date, format: .short)
        case .company: return company?.name ?? ""
        case .contact: return contact?.getFullName() ?? ""
        case .type: return type ?? ""
        case .link: return link ?? ""
        case .notes: return notes ?? ""
        case .pay: return pay ?? ""
        default: return ""
        }
    }
    
    func setValue(value: Any, forField field: ModelFieldType) {
        switch field {
        case .title: if let title = value as? String { self.title = title }
        case .location: if let location = value as? String { self.location = location }
        case .type: if let type = value as? String { self.type = type }
        case .date:
            if let date = value as? Date { self.date = date }
            else if let swString = value as? String, let swFromString = DateUtilities.dateFrom(string: swString, format: .short) { self.date = swFromString }
        case .pay: if let pay = value as? String { self.pay = pay }
        case .link: if let link = value as? String { self.link = link }
        case .notes: if let notes = value as? String { self.notes = notes }
        case .company: if let company = value as? String { DataController.setCompany(name: company, for: self) }
        case .contact: if let contact = value as? String { DataController.setPerson(name: contact, for: self) }
        default:
            break
        }
    }
    
}
