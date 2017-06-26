//
//  People.swift
//  jobagent
//
//  Created by Brenden West on 6/22/17.
//
//

import UIKit
import CoreData

@objc internal class People: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    var selectedCompany: String?
    
    let segueId = "showPersonDetail"
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {

        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // create array of toolbar button properties for add & edit
        let buttons = [
            [4,"insertItem",self],
            [2,"",self]
        ]
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: Common.customBarButtons(buttons))
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // fetch data
        print("People willAppear")
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func configureCell(cell: UITableViewCell, person: NSManagedObject) {
        
    }
    
    func insertItem() {
        self.performSegue(withIdentifier: segueId, sender: nil)
    }
    
    // Table methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        let record = self.fetchedResultsController.object(at: indexPath) as! Person
        
        cell.textLabel?.text = record.getFullName()

        //Populate the cell from the object
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection: Int) -> String? {
        return "Contacts"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: segueId, sender: tableView)
       
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            let person = self.fetchedResultsController.object(at: indexPath as IndexPath) as! Person
            
            self.managedObjectContext.delete(person)
            do {
                try self.managedObjectContext.save()
                self.tableView.reloadData()
            } catch let error {
                print(error)
            }
            
        }
        return [delete]
    }
    
    // segue to person detail

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case segueId:
            
            let detailVC = segue.destination as! PersonDetail
            if (sender as? UITableView) == self.tableView {
                let indexPath = tableView.indexPathForSelectedRow!
                let person = fetchedResultsController.object(at: indexPath) as! Person
                detailVC.selectedPerson = person
            } else {
                detailVC.selectedPerson = Person(context: self.managedObjectContext)
            }
            
        default:
            print("Unknown segue: \(String(describing: segue.identifier))")
        }
        
    }
    
    // pragma mark - FetchResultsController methods
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.tableView.reloadData()
    }
    
}
