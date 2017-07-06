//
//  PersonDetail.swift
//  jobagent
//
//  Created by Brenden West on 6/15/17.
//
//

import UIKit
import CoreData
import MessageUI

class Person: NSManagedObject {
    
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var notes: String?
    @NSManaged var link: String?
    @NSManaged var phone: String?
    @NSManaged var email: String?
    @NSManaged var company: Company?
    @NSManaged var job: Job?
    
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

@objc internal class PersonDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, EditItemDelegate, PickListDelegate {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnContactActions: UISegmentedControl!

    weak var selectedPerson: Person?
    var currentKey: String = ""
    
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
        self.automaticallyAdjustsScrollViewInsets = false;
        
        self.tableView?.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // trigger text fields to save contents
        self.view.window?.endEditing(true)

        if let name = self.selectedPerson?.firstName, !name.isEmpty {
            do {
                try self.selectedPerson?.managedObjectContext?.save()
            } catch let error {
                print("Error on save: \(error)")
            }
        } else {
            // delete empty record from data source
            self.selectedPerson?.managedObjectContext?.delete(self.selectedPerson!)
        }
        
    }

    // MARK: TableView methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        let reuseIdentifier = (field["isText"] as? Bool)! ? "editableCell" : "cell"
        let itemKey: String = field["key"] as! String
        
        var cell:UITableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.default,  reuseIdentifier: reuseIdentifier)
        }
        
        var label: UILabel

        var text: String
        if itemKey == "name" {
            text = (self.selectedPerson?.getFullName())!
        } else if itemKey == "company" {
                text = self.selectedPerson?.company?.name ?? ""
        } else {
            text = self.selectedPerson?.value(forKey: itemKey) as? String ?? ""
        }

        if (cell?.contentView.subviews.isEmpty)! {
            label = customLabel(from: nil)
            label.text = field["label"] as? String
            cell?.contentView.addSubview(label)

            if reuseIdentifier == "editableCell" {
                let detailText = UITextField.init(frame: detailWidth)
                detailText.text = text
                detailText.delegate = self;
                detailText.tag = indexPath.row;
                detailText.returnKeyType = UIReturnKeyType.done;
                
                if itemKey == "phone" {
                    detailText.keyboardType = UIKeyboardType.phonePad
                } else if itemKey == "email" {
                    detailText.keyboardType = UIKeyboardType.emailAddress
                }

                cell?.contentView.addSubview(detailText)
            } else {
                let detailText = UILabel.init(frame: detailWidth)
                detailText.text = text
                cell?.contentView.addSubview(detailText)
                cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
            }

        } else {
            if reuseIdentifier == "editableCell" {
                let detailText = cell?.contentView.subviews[1] as! UITextField
                detailText.text = text
            } else {
                let detailText = customDetail(from: cell)
                detailText.text = text
            }

        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // store name if entered
        self.view.window?.endEditing(true)

        // store ID of selected row for use when returning from child vc
        self.currentKey = self.fields[indexPath.row]["key"] as! String
        let cell = tableView.cellForRow(at: indexPath)
        
        switch self.currentKey {
        case "type":
            let cell = tableView.cellForRow(at: indexPath)
            
            let pickList = PickList()
            pickList.header = NSLocalizedString("STR_SEL_TYPE", comment: "")
            pickList.options = contactTypes
            pickList.selectedItem = customDetail(from: cell).text
            pickList.delegate = self as PickListDelegate
            self.navigationController?.pushViewController(pickList, animated: true)
            break

        default:
            self.performSegue(withIdentifier: "showItem", sender: cell)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let cell = sender as? UITableViewCell {
                let vc = segue.destination as! EditItemVC
                vc.labelText = customLabel(from: cell).text
                vc.itemText =  customDetail(from: cell).text
                vc.delegate = self
                
            }
        }
    }

    // MARK: TextView methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // the user pressed the "Done" button, so dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        switch textField.tag {
        case 0:

            if let person = Person.getNameParts(textField.text) {
                self.selectedPerson?.firstName = person.firstName
                self.selectedPerson?.lastName = person.lastName
            }
            break
        case 1:
            self.selectedPerson?.title = textField.text
            break
        case 2:
            self.selectedPerson?.setCompany(name: textField.text)
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
    
    // MARK: protocol methods
    
    func pickHandler(_ item: String) {
        // on return from pickList view
        self.textEditHandler(item)
    }
    
    func textEditHandler(_ itemText: String) {
        // on return full-text edit view
        self.selectedPerson?.setValue(itemText, forKey: self.currentKey)
        self.tableView?.reloadData()

    }
    
    // MARK: segment actions
    
     @IBAction func segmentAction(sender: Any?) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex

        if index == 0, let phone = self.selectedPerson?.phone, !phone.isEmpty {
            UIApplication.shared.open(URL.init(string: "tel://\(phone)")! , options: [:], completionHandler: nil)
        } else if index == 1, let email = self.selectedPerson?.email, !email.isEmpty {
            self.sendMail(email)
            
        }  else if index == 2, let fullName = self.selectedPerson?.getFullName(), !fullName.isEmpty {
            let company = self.selectedPerson?.company?.name ?? ""
            let urlStr = "https://www.linkedin.com/vsearch/p?keywords=\(fullName)+\(company)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)

            UIApplication.shared.open(URL.init(string: urlStr!)! , options: [:], completionHandler: nil)
 
        }
        
    }
    
    func sendMail(_ recipient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setToRecipients([recipient])
            mailController.setMessageBody("Hi \(String(describing: self.selectedPerson?.firstName))", isHTML: false)
            present(mailController, animated: true)
            
        } else {
            _ = UIAlertController(title: "mail error", message: "can't send mail" , preferredStyle: UIAlertControllerStyle.alert)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
