//
//  CompanyDetail.swift
//  jobagent
//
//  Created by Brenden West on 6/27/17.
//
//

import UIKit
import CoreData

class Company: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var location: String?
    @NSManaged var notes: String?
    @NSManaged var toJobs: Set<Job>?
    @NSManaged var toPerson: Set<Person>?
    @NSManaged var toEvent: Set<Event>?
    
    // TBD CoreDataGeneratedAccessors
    
}

@objc internal class CompanyDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, EditItemDelegate, PickListDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnCompanyActions: UISegmentedControl!

    let detailWidth = CGRect(x:65.0, y:0.0, width:UIScreen.main.bounds.size.width - 80, height:44.0)

    weak var selectedCompany: Company?
    var managedObjectContext: NSManagedObjectContext!
    var currentKey: String = ""
    
    let fields = [
        ["label":NSLocalizedString("STR_COMPANY", comment: ""), "key": "name", "isText": true],
        ["label":NSLocalizedString("STR_LOCATION", comment: ""), "key": "location", "isText": false],
        ["label":NSLocalizedString("STR_TYPE", comment: ""), "key": "type", "isText": false],
        ["label":NSLocalizedString("STR_NOTES", comment: ""), "key": "notes", "isText": false],
    ]

    let companyTypes = [
        NSLocalizedString("STR_CO_TYPE_DEFAULT", comment: ""),
        NSLocalizedString("STR_CO_TYPE_AGENCY", comment: ""),
        NSLocalizedString("STR_CO_TYPE_GOVT", comment: ""),
        NSLocalizedString("STR_CO_TYPE_EDUC", comment: ""),
        NSLocalizedString("STR_OTHER", comment: "")
    ];

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false;

        self.btnCompanyActions.addTarget(self, action: #selector(segmentAction(sender:)), for: .valueChanged)
        
        self.tableView?.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // trigger text fields to save contents
        self.view.window?.endEditing(true)

        if let name = self.selectedCompany?.name, !name.isEmpty {
            do {
                try self.selectedCompany?.managedObjectContext?.save()
            } catch let error {
                print("Error on save: \(error)")
            }
        } else {
            // delete empty record from data source
            self.selectedCompany?.managedObjectContext?.delete(self.selectedCompany!)
        }
    }

    // MARK: TabelView methods
    
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
            cell = UITableViewCell(style: UITableViewCellStyle.default,
                                   reuseIdentifier: reuseIdentifier)
        }
        
        var label: UILabel
        let text = self.selectedCompany?.value(forKey: itemKey) as? String ?? ""

        if (cell?.contentView.subviews.isEmpty)! {
            label = UILabel.init(frame: CGRect(x:10.0, y:10.0, width:60.0, height:25.0))
            
            label.text = field["label"] as? String
            label.font = UIFont.systemFont(ofSize: 10.0)
            label.textColor = UIColor.gray
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
                let detailText = cell?.contentView.subviews[1] as! UILabel
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
            pickList.options = companyTypes
            pickList.selectedItem = cell?.detailTextLabel?.text
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
                vc.labelText = (cell.contentView.subviews.first as! UILabel).text
                vc.itemText =  (cell.contentView.subviews[1] as! UILabel).text
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
            self.selectedCompany?.name = textField.text
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

        self.selectedCompany?.setValue(itemText, forKey: self.currentKey)
        self.tableView?.reloadData()
        
    }
    
    // MARK: segment actions
    
    @IBAction func segmentAction(sender: Any?) {
        let index = (sender as! UISegmentedControl).selectedSegmentIndex
    }
}
