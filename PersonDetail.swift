//
//  PersonaDetail.swift
//  jobagent
//
//  Created by Brenden West on 6/15/17.
//
//

import UIKit
import CoreData
import MessageUI

//#import "EditItemVC.h"
//#import "PickList.h"

class Person: NSManagedObject {
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var title: String?
    @NSManaged var company: String?
    @NSManaged var type: String?
    @NSManaged var notes: String?
    @NSManaged var link: String?
    @NSManaged var phone: String?
    @NSManaged var email: String?
    
    func getFullName() -> String {
        
        let first = self.firstName ?? ""
        let last = self.lastName ?? ""
        let separator = !first.isEmpty && !last.isEmpty ? " " : ""
        
        return "\(first)\(separator)\(last)"
        
    }
    
}

@objc internal class PersonDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnContactActions: UISegmentedControl!

    let detailWidth = CGRect(x:65.0, y:0.0, width:UIScreen.main.bounds.size.width - 80, height:44.0)
    
    weak var selectedPerson: Person?
    var managedObjectContext: NSManagedObjectContext!
    
//    NSString *editedItemId;
    
    let fields = [
        ["label":NSLocalizedString("STR_NAME", comment: ""), "key": "name", "isText": true],
        ["label":NSLocalizedString("STR_TITLE", comment: ""), "key": "title", "isText": true],
        ["label":NSLocalizedString("STR_COMPANY", comment: ""), "key": "company", "isText": true],
        ["label":NSLocalizedString("STR_TYPE", comment: ""), "key": "type", "isText": false],
        ["label":NSLocalizedString("STR_PHONE", comment: ""), "key": "phone", "isText": true],
        ["label":NSLocalizedString("STR_EMAIL", comment: ""), "key": "email", "isText": true],
        ["label":NSLocalizedString("STR_NOTES", comment: ""), "key": "notes", "isText": false],
    ]

    let contactTypes = [
        NSLocalizedString("STR_CONTACT_TYPE_RECRUIT", comment: ""),
        NSLocalizedString("STR_CONTACT_TYPE_REF", comment: ""),
        NSLocalizedString("STR_OTHER", comment: "")
    ];
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        let itemKey: String = field["key"] as! String
        
        let cell = tableView.dequeueReusableCell(withIdentifier: itemKey)
            ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: itemKey)
        
        var label: UILabel

        if cell.contentView.subviews.isEmpty {
            label = UILabel.init(frame: CGRect(x:10.0, y:10.0, width:60.0, height:25.0))
            
            label.text = field["label"] as? String
            label.font = UIFont.systemFont(ofSize: 10.0)
            label.textColor = UIColor.gray
            cell.contentView.addSubview(label)
            
            var text: String
            if itemKey == "name" {
                text = (self.selectedPerson?.getFullName())!
            } else {
                text = self.selectedPerson?.value(forKey: itemKey) as? String ?? ""
            }

            if (field["isText"] as? Bool)! {
                let detailText = UITextField.init(frame: detailWidth)
                detailText.text = text
                detailText.delegate = self;
                detailText.tag = indexPath.row;
                detailText.returnKeyType = UIReturnKeyType.done;
                
                cell.contentView.addSubview(detailText)
            } else {
                let detailText = UILabel.init(frame: detailWidth)
                detailText.text = text
                cell.contentView.addSubview(detailText)
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
            }

        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    // pragma mark TextView methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // the user pressed the "Done" button, so dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        switch textField.tag {
        case 0:
            if let person = getNameParts(textField.text) {
                self.selectedPerson?.firstName = person.firstName
                self.selectedPerson?.lastName = person.lastName
            }
            break
        case 1:
            self.selectedPerson?.title = textField.text
            break
        case 2:
            self.selectedPerson?.company = textField.text
            break
        case 4:
            self.selectedPerson?.phone = textField.text
            break
        case 5:
            self.selectedPerson?.email = textField.text
            break
        default:
            break
        }
 
    }
    
    func getNameParts(_ name: String?) -> (firstName: String, lastName: String)? {
        if let name = name {
            let nameArray = name.components(separatedBy: " ")
            let first = nameArray[0]
            let last = nameArray.count > 1 ? nameArray[1] : ""
            return (first, last)
        }
        
        return nil // input strint was empty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        if let name = self.selectedPerson?.firstName, !name.isEmpty {
            do {
                print("save")
                try self.selectedPerson?.managedObjectContext?.save()
            } catch let error {
                print("Save error \(error)")
            }
        } else {
            // delete empty person from data source
            self.selectedPerson?.managedObjectContext?.delete(self.selectedPerson!)
        }
        
    }
    
}
