//
//  DataController.swift
//  jobagent
//
//  Created by Brenden West on 6/29/17.
//
//

import Foundation
import CoreData

class DataController {
    
    // associate company with target
    static func setCompany(name: String?, for target: NSManagedObject) {
        if let name = name, !name.isEmpty {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Company")
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
            do {
                let fetchedResults = try target.managedObjectContext?.fetch(fetchRequest) as! [Company]
                var company: Company
                if fetchedResults.isEmpty {
                    company = Company(context: target.managedObjectContext!)
                    company.name = name
                } else {
                    company = fetchedResults.first!
                }
                if let person = target as? Person {
                    company.addToPeople(person)
                }
                else if let job = target as? Job {
                    company.addToJobs(job)
                }
                else if let event = target as? Event {
                    company.addToEvents(event)
                }
                do {
                    try target.managedObjectContext?.save()
                } catch let error {
                    print("Error on save: \(error)")
                }
                
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        }
    }

    // associate person with target
    static func setPerson(name: String?, for target: NSManagedObject) {
        if let name = name, !name.isEmpty {

            let parts = Person.getNameParts(name)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
            if !parts!.lastName.isEmpty && !parts!.firstName.isEmpty {
                fetchRequest.predicate = NSPredicate(format: "lastName like[c] %@ AND firstName LIKE[c] %@", parts!.lastName, parts!.firstName)
            } else {
                // only one name part entered
                fetchRequest.predicate = NSPredicate(format: "lastName like[c] %@ OR firstName LIKE[c] %@", parts!.lastName, parts!.firstName)
            }

            do {
                let fetchedResults = try target.managedObjectContext?.fetch(fetchRequest) as! [Person]
                var person: Person
                if fetchedResults.isEmpty {
                    person = Person(context: target.managedObjectContext!)
                    person.firstName = parts?.firstName
                    person.lastName = parts?.lastName
                } else {
                    person = fetchedResults.first!
                }
                if let job = target as? Job {
                    job.contact = person
                }
                else if let company = target as? Company {
                    company.addToPeople(person)
                }
                else if let event = target as? Event {
                    event.contact = person
                }
                do {
                    try target.managedObjectContext?.save()
                } catch let error {
                    print("Error on save: \(error)")
                }
                
            } catch {
                fatalError("Failed to fetch employees: \(error)")
            }
        }
    }
}
