//
//  EventDetail.swift
//  jobagent
//
//  Created by Brenden West on 7/11/17.
//
//

import UIKit
import CoreData

@objc internal class EventDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, TextFieldTableViewCellDelegate, DatePickerCellDelegate, EditItemDelegate, PickListDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    weak var selectedEvent: Event?
    var currentKey: String = ""
    var datePickerIndexPath: IndexPath?
    var datePickerVisible: Bool { return datePickerIndexPath != nil }

    let fields : [ModelFieldType] = [.title, .date, .type, .priority, .contact, .company, .job, .notes]

    let eventTypes = [
        NSLocalizedString("STR_EVENT_TYPE_EMAIL", comment: ""),
        NSLocalizedString("STR_EVENT_TYPE_ONLINE", comment: ""),
        NSLocalizedString("STR_EVENT_TYPE_PHONE", comment: ""),
        NSLocalizedString("STR_EVENT_TYPE_INPERSON", comment: ""),
        NSLocalizedString("STR_EVENT_TYPE_INFORM", comment: ""),
        NSLocalizedString("STR_EVENT_TYPE_FAIR", comment: ""),
        NSLocalizedString("STR_OTHER", comment: "")
    ]
    
    let priorities = [
        NSLocalizedString("STR_BTN_LOW", comment: ""),
        NSLocalizedString("STR_BTN_MED", comment: ""),
        NSLocalizedString("STR_BTN_HIGH", comment: "")]

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        tableView?.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldTableViewCell")
        tableView?.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "DatePickerCell")
        
        self.tableView?.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // trigger text fields to save contents
        self.view.window?.endEditing(true)
        
        if let name = self.selectedEvent?.title, !name.isEmpty  {
            do {
                try self.selectedEvent?.managedObjectContext?.save()
            } catch let error {
                print("Error on save: \(error)")
            }
        } else {
            // delete empty record from data source
            self.selectedEvent?.managedObjectContext?.delete(self.selectedEvent!)
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
            cell.configureWithField(field: field, currentDate: self.selectedEvent?.valueFor(field: field) as? Date)
            return cell
        } else {
            let cell = self.tableView?.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            let field = calculateFieldForIndexPath(indexPath: indexPath)
            cell.configureWithField(field: field, andValue: self.selectedEvent?.stringValueFor(field: field))
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
        case .type, .priority:
            
            let pickList = PickList()
            pickList.header = NSLocalizedString("STR_SEL_TYPE", comment: "")
            pickList.options = (field == .priority) ? priorities : eventTypes
            pickList.selectedItem = self.selectedEvent?.stringValueFor(field: field)
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
                vc.itemText =  self.selectedEvent?.stringValueFor(field: field)
                vc.delegate = self
                
            }
        }
    }

    // MARK: - TextFieldTableViewCellDelegate
    
    func field(field: ModelFieldType, changedValueTo value: String) {
        self.selectedEvent?.setValue(value: value, forField: field)
        self.tableView?.reloadData()
    }
    
    func fieldDidBeginEditing(field: ModelFieldType) {
        dismissDatePickerRow()
    }
    
    // MARK: - DatePickerTableViewCellDelegate methods
    func dateChangedForField(field: ModelFieldType, toDate date: Date) {
        self.selectedEvent?.setValue(value: date, forField: field)
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
        self.selectedEvent?.setValue(itemText, forKey: self.currentKey)
        self.tableView?.reloadData()
    }
}
