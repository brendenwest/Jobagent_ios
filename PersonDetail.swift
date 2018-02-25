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

@objc internal class PersonDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, TextFieldTableViewCellDelegate, MFMailComposeViewControllerDelegate, EditItemDelegate, PickListDelegate {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnContactActions: UISegmentedControl!

    weak var selectedPerson: Person?
    var currentKey: String = ""
    
    let fields : [ModelFieldType] = [.name, .title, .company, .type, .phone, .email, .notes]

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
        
        self.tableView?.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextFieldTableViewCell")

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
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
        cell.configureWithField(field: field, andValue: self.selectedPerson?.stringValueFor(field: field))
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // store name if entered
        self.view.endEditing(true)
        
        let field = fields[indexPath.row]

        // store ID of selected row for use when returning from child vc
        self.currentKey = field.rawValue
        
        switch self.currentKey {
        case "type":
            
            let pickList = PickList()
            pickList.header = NSLocalizedString("STR_SEL_TYPE", comment: "")
            pickList.options = contactTypes
            pickList.selectedItem = self.selectedPerson?.stringValueFor(field: field)
            pickList.delegate = self as PickListDelegate
            self.navigationController?.pushViewController(pickList, animated: true)
            break

        default:
            self.performSegue(withIdentifier: "showItem", sender: field)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let field = sender as? ModelFieldType {
                let vc = segue.destination as! EditItemVC
                vc.labelText = field.localized
                vc.itemText = self.selectedPerson?.stringValueFor(field: field)
                vc.delegate = self
                
            }
        }
    }

    // MARK: - TextFieldTableViewCellDelegate
    
    func field(field: ModelFieldType, changedValueTo value: String) {
        self.selectedPerson?.setValue(value: value, forField: field)
        self.tableView?.reloadData()
    }
    
    func fieldDidBeginEditing(field: ModelFieldType) {

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
