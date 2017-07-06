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

    // add new company item if not exists
    func setCompany(name: String?) {
        DataController.setCompany(name: name, for: self)
    }

    func setContact(name: String?) {
        DataController.setPerson(name: name, for: self)
    }

}

@objc internal class JobDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, EditItemDelegate, PickListDelegate {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnJobActions: UISegmentedControl!

    weak var selectedJob: Job?
    var isFavorite = false // true when entering from Jobs
    var currentKey: String = ""

    let fields = [
        ["label":NSLocalizedString("STR_TITLE", comment: ""), "key": "title", "isText": true],
        ["label":NSLocalizedString("STR_COMPANY", comment: ""), "key": "company", "isText": true],
        ["label":NSLocalizedString("STR_LOCATION", comment: ""), "key": "location", "isText": true],
//        ["label":NSLocalizedString("STR_DATE", comment: ""), "key": "date", "isText": true],
        ["label":NSLocalizedString("STR_TYPE", comment: ""), "key": "type", "isText": false],
        ["label":NSLocalizedString("STR_NOTES", comment: ""), "key": "notes", "isText": false],
        ["label":NSLocalizedString("STR_CONTACT", comment: ""), "key": "contact", "isText": true],
        ["label":NSLocalizedString("STR_PAY", comment: ""), "key": "pay", "isText": true],
        ["label":NSLocalizedString("STR_LINK", comment: ""), "key": "link", "isText": false],
    ]
    
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
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        let reuseIdentifier = (field["isText"] as? Bool)! ? "editableCell" : "cell"
        let itemKey: String = field["key"] as! String
        
        var cell:UITableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        }
        
        var label: UILabel
        var text: String
        
        if itemKey == "company" {
            text = self.selectedJob?.company?.name ?? ""
        } else if itemKey == "contact" {
                text = self.selectedJob?.contact?.getFullName() ?? ""
        } else {
            text = self.selectedJob?.value(forKey: itemKey) as? String ?? ""
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
            pickList.options = jobTypes
            pickList.selectedItem = customLabel(from: cell).text
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
            self.selectedJob?.title = textField.text
            break
        case 1:
            self.selectedJob?.setCompany(name: textField.text)
            break
        case 2:
            self.selectedJob?.location = textField.text
            break
        case 5:
            self.selectedJob?.setContact(name: textField.text)
            break
        case 6:
            self.selectedJob?.pay = textField.text
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
