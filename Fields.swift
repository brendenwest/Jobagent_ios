//
//  Fields.swift
//  jobagent
//
//  Created by Brenden West on 7/16/17.
//
//

import Foundation

enum ModelFieldType: String {
    case title = "title"
    case location = "location"
    case date = "date"
    case company = "company"
    case contact = "contact"
    case type = "type"
    case link = "link"
    case notes = "notes"
    case pay = "pay"
    case name = "name"
    case phone = "phone"
    case email = "email"
    case job = "job"
    case priority = "priority"
    
    var isEditable: Bool {
        switch self {
        case .date, .link, .notes, .type, .priority: return false
        default: return true
        }
    }
    
    var hasDisclosure: Bool {
        switch self {
        case .type, .link, .notes, .priority: return true
        default: return false
        }
    }
    
    var localized: String {
        switch self {
        case .title: return NSLocalizedString("STR_TITLE", comment: "")
        case .location: return NSLocalizedString("STR_LOCATION", comment: "")
        case .date: return NSLocalizedString("STR_DATE", comment: "")
        case .company: return NSLocalizedString("STR_COMPANY", comment: "")
        case .contact: return NSLocalizedString("STR_CONTACT", comment: "")
        case .type: return NSLocalizedString("STR_TYPE", comment: "")
        case .link: return NSLocalizedString("STR_LINK", comment: "")
        case .notes: return NSLocalizedString("STR_NOTES", comment: "")
        case .pay: return NSLocalizedString("STR_PAY", comment: "")
        case .name: return NSLocalizedString("STR_NAME", comment: "")
        case .phone: return NSLocalizedString("STR_PHONE", comment: "")
        case .email: return NSLocalizedString("STR_EMAIL", comment: "")
        case .priority: return NSLocalizedString("STR_PRIORITY", comment: "")
        default: return self.rawValue
        }
    }
}
