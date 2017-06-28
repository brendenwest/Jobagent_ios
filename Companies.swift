//
//  Companies.swift
//  jobagent
//
//  Created by Brenden West on 6/27/17.
//
//

import UIKit
import CoreData

@objc internal class Companies: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext!
    let segueId = "showCompanyDetail"

    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Company")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
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
        
        // support embedded text fields
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        // fetch data
        print("viewWillAppear")
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        self.tableView.reloadData()
    }

    func insertItem() {
        self.performSegue(withIdentifier: segueId, sender: nil)
    }

    // MARK: TableView methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        let record = self.fetchedResultsController.object(at: indexPath) as! Company
        
        cell.textLabel?.text = record.name
        
        //Populate the cell from the object
        return cell
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
            let company = self.fetchedResultsController.object(at: indexPath as IndexPath) as! Company
            
            self.managedObjectContext.delete(company)
            do {
                try self.managedObjectContext.save()
                self.tableView.reloadData()
            } catch let error {
                print(error)
            }
        }
        return [delete]
    }

    // MARK: segue to detail
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case segueId:
            
            let detailVC = segue.destination as! CompanyDetail
            if (sender as? UITableView) == self.tableView {
                let indexPath = tableView.indexPathForSelectedRow!
                let company = fetchedResultsController.object(at: indexPath) as! Company
                detailVC.selectedCompany = company
            } else {
                detailVC.selectedCompany = Company(context: self.managedObjectContext)
            }
            
        default:
            print("Unknown segue: \(String(describing: segue.identifier))")
        }
        
    }
    
    // MARK: FetchResultsController methods
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.tableView.reloadData()
    }

}
