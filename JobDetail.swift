//
//  JobDetail.swift
//  jobagent
//
//  Created by Brenden West on 6/28/17.
//
//

import UIKit
import CoreData
import MessageUI

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
    
    var isEditable: Bool {
        switch self {
        case .date, .link, .notes, .type: return false
        default: return true
        }
    }
    
    var hasDisclosure: Bool {
        switch self {
        case .type, .link, .notes: return true
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
        default: return self.rawValue
        }
    }
}

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

@objc internal class JobDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, TextFieldTableViewCellDelegate, DatePickerCellDelegate, MFMailComposeViewControllerDelegate, EditItemDelegate, PickListDelegate {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnJobActions: UISegmentedControl!

    weak var selectedJob: Job?
    var isFavorite = false // true when entering from Jobs
    var currentKey: String = ""
    var datePickerIndexPath: IndexPath?
    var datePickerVisible: Bool { return datePickerIndexPath != nil }
    
    let fields : [ModelFieldType] = [.title, .company, .location, .date, .type, .contact, .pay, .notes, .link]

    let jobTypes = [
        NSLocalizedString("STR_JOB_TYPE_FT", comment: ""),
        NSLocalizedString("STR_JOB_TYPE_PT", comment: ""),
        NSLocalizedString("STR_JOB_TYPE_CON", comment: ""),
        NSLocalizedString("STR_JOB_TYPE_C2C", comment: ""),
        NSLocalizedString("STR_JOB_TYPE_INTERN", comment: ""),
        NSLocalizedString("STR_JOB_TYPE_VOL", comment: ""),
        NSLocalizedString("STR_OTHER", comment: "")
    ]

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        tableView?.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldTableViewCell")
        tableView?.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        
        self.btnJobActions.addTarget(self, action: #selector(segmentAction(sender:)), for: .valueChanged)
        
        self.tableView?.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // trigger text fields to save contents
        self.view.window?.endEditing(true)

        if let name = self.selectedJob?.title, !name.isEmpty, isFavorite  {
            do {
                try self.selectedJob?.managedObjectContext?.save()
            } catch let error {
                print("Error on save: \(error)")
            }
        } else {
            // delete empty record from data source
            self.selectedJob?.managedObjectContext?.delete(self.selectedJob!)
        }
    }
    
    // MARK: TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datePickerVisible ? fields.count + 1 : fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if datePickerVisible && datePickerIndexPath! == indexPath {
            let cell = self.tableView?.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
            cell.delegate = self
            
            // the field will correspond to the index of the row before this one.
            let field = fields[indexPath.row - 1]
            cell.configureWithField(field: field, currentDate: self.selectedJob?.valueFor(field: field) as? Date)
            return cell
        } else {
            let cell = self.tableView?.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            let field = calculateFieldForIndexPath(indexPath: indexPath)
            cell.configureWithField(field: field, andValue: self.selectedJob?.stringValueFor(field: field))
            cell.delegate = self
        
            return cell
        }
    }

    func calculateFieldForIndexPath(indexPath: IndexPath) -> ModelFieldType {
        if datePickerVisible && datePickerIndexPath!.section == indexPath.section {
            if datePickerIndexPath!.row == indexPath.row {
                // we are the date picker. Pick the field below me
                return fields[indexPath.row - 1]
            } else if datePickerIndexPath!.row > indexPath.row {
                // we are "below" the date picker. Just return the field.
                return fields[indexPath.row]
            } else {
                // we are above the datePicker, so we should substract one from the current row index
                return fields[indexPath.row - 1]
            }
        } else {
            // The date picker is not showing or not in my section, just return the usual field.
            return fields[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.view.endEditing(true)
        
        var fieldIndex = indexPath.row
        // if selected row is below datepicker, recalculate index
        if let datePickerRow = datePickerIndexPath?.row, datePickerRow < indexPath.row {
            fieldIndex -= 1
        }
        let field = fields[fieldIndex]
        self.currentKey = field.rawValue
        
        // hide/show inline date picker
        tableView.beginUpdates()
        if datePickerVisible {

            // close datepicker
            tableView.deleteRows(at: [datePickerIndexPath!], with: .fade)
            self.datePickerIndexPath = nil
            
        } else if field == .date {
            self.datePickerIndexPath = IndexPath(row:indexPath.row+1, section: indexPath.section)
            tableView.insertRows(at: [self.datePickerIndexPath!], with: .fade)
        }

        tableView.endUpdates()


        // show detail editors if needed
        switch field {
        case .type:
            
            let pickList = PickList()
            pickList.header = NSLocalizedString("STR_SEL_TYPE", comment: "")
            pickList.options = jobTypes
            pickList.selectedItem = self.selectedJob?.stringValueFor(field: field)
            pickList.delegate = self as PickListDelegate
            self.navigationController?.pushViewController(pickList, animated: true)
            break
        case .link, .notes :
            self.performSegue(withIdentifier: "showItem", sender: field)
        default:
            break
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let field = sender as? ModelFieldType {
                let vc = segue.destination as! EditItemVC
                vc.labelText = field.localized
                vc.itemText =  self.selectedJob?.stringValueFor(field: field)
                vc.delegate = self
                
            }
        }
    }

    // MARK: - TextFieldTableViewCellDelegate
    
    func field(field: ModelFieldType, changedValueTo value: String) {
        self.selectedJob?.setValue(value: value, forField: field)
        self.tableView?.reloadData()
    }

    func fieldDidBeginEditing(field: ModelFieldType) {
        dismissDatePickerRow()
    }
    
    // MARK: - DatePickerTableViewCellDelegate methods
    func dateChangedForField(field: ModelFieldType, toDate date: Date) {
        self.selectedJob?.setValue(value: date, forField: field)
        self.tableView?.reloadData()
    }

    func dismissDatePickerRow() {
        if !datePickerVisible { return }
        
        tableView?.beginUpdates()
        tableView?.deleteRows(at: [datePickerIndexPath!], with: .fade)
        datePickerIndexPath = nil
        tableView?.endUpdates()
    }

    func datePickerShouldAppearAt(indexPath: IndexPath) -> Bool {
        let field = calculateFieldForIndexPath(indexPath: indexPath)
        return field == .date
    }

    func datePickerIsRightBelowMe(indexPath: IndexPath) -> Bool {
        if datePickerVisible && datePickerIndexPath!.section == indexPath.section {
            if indexPath.section != datePickerIndexPath!.section { return false }
            else { return indexPath.row == datePickerIndexPath!.row - 1 }
        } else { return false }
    }
    
    // MARK: protocol methods

    func pickHandler(_ item: String) {
        // on return from pickList view
        self.textEditHandler(item)
    }
    
    func textEditHandler(_ itemText: String) {
        // on return full-text edit view
        self.selectedJob?.setValue(itemText, forKey: self.currentKey)
        self.tableView?.reloadData()
    }

    // MARK: segment actions
 
    @IBAction func segmentAction(sender: Any?) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex
        switch index {
        case 0:
            self.isFavorite = true
            self.navigationController?.popViewController(animated: true)
            break
        case 1:
            self.shareJob()
            break
        case 2:
            let webVC = WebVC()
            webVC.requestedURL = self.selectedJob?.link
            webVC.title = "Job Listing"
            self.navigationController?.pushViewController(webVC, animated: true)
            break
        default:
            break
        }
    }
 
    func shareJob() {
        if let link = self.selectedJob?.link {
            let tinyUrl = URL.init(string: "http://tinyurl.com/api-create.php?url=\(link)")
            do {
                let shortUrl = try String(contentsOf: tinyUrl!, encoding: String.Encoding.ascii)
                let postText = "\(String(describing: self.selectedJob?.title)) - \(shortUrl)"
                let activityController = UIActivityViewController(activityItems: [postText, URL.init(string: "") as Any], applicationActivities: nil)
                activityController.setValue("Job lead - \(String(describing: self.selectedJob?.title))", forKey: "subject")
                activityController.excludedActivityTypes = [
                    UIActivityType.copyToPasteboard,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.assignToContact
                ]
                
                self.present(activityController, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
    }
 
}
