//
//  SearchResults.swift
//  jobagent
//
//  Created by Brenden West on 6/29/17.
//
//

import UIKit
import Alamofire

@objc internal class SearchResults: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var currentSection = 0
    var jobsAll = [[String: Any]]()
    var jobsForSite : [[String: Any]] {
        get {
            // get search tag for selected site
            let tag = siteList[btnJobSites.selectedSegmentIndex]["tag"] ?? ""
            return jobsAll.filter() {
                ($0["link"] as! String).range(of:tag) != nil
            }

        }
    }

    // values set by prepare-for-segue
    var keyword = ""
    var location = ""
    var locale = "US"

    var currentSearch = [String: String]()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnJobSites: UISegmentedControl!
    @IBOutlet weak var lblSearch: UILabel?
    @IBOutlet weak var uiLoading: UIActivityIndicatorView?

    let segueId = "showCompanyDetail"
    let cellId = "cell"
    
    let siteList = [
        ["displayName":"CareerBuilder", "domain": "http://www.careerbuilder.com", "tag": "careerbuilder"],
        ["displayName":"Jobs by ", "domain": "http://www.indeed.com", "tag": "indeed"],
        ["displayName":"classifieds by Oodle", "domain": "http://www.oodle.com", "tag": "oodle"],
        ["displayName":"LinkUp", "domain": "http://www.linkup.com", "tag": "linkup"]
    ]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentSearch = [
            "keyword":self.keyword,
            "location":self.location,
            "locale":self.locale
        ]

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadJobs()
        
    }
    
    // MARK: TabelView methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobsForSite.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        let job = jobsForSite[indexPath.row]

        let pubdate = Common.getShortDate(job["pubdate"] as? String ?? "")!
        let company = job["company"] as? String ?? ""
        let location = job["location"] as? String ?? ""
        
        cell.textLabel?.text = job["title"] as? String ?? ""
        cell.detailTextLabel?.text = "\(pubdate) ~ \(company) ~ \(location)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
         return cell;
    }
    
    @IBAction func switchJobSite(sender: Any?) {
        let index = (sender as? UISegmentedControl)?.selectedSegmentIndex ?? 0
        print(index)
        print(jobsForSite.count)
        self.tableView?.reloadData()
        
    }
    
    func loadJobs() {
        
        let settings = UserDefaults.standard

        var searchUrl = "\(appDelegate.configuration["apiDomainProd"]!)\(appDelegate.configuration["searchUrl"]!)"
        searchUrl = searchUrl.replacingOccurrences(of: "<location>", with: self.currentSearch["location"]!)
        searchUrl = searchUrl.replacingOccurrences(of: "<kw>", with: self.currentSearch["keyword"]!)
        searchUrl = searchUrl.replacingOccurrences(of: "<country>", with: self.currentSearch["locale"]!)
        searchUrl = searchUrl.replacingOccurrences(of: "<max>", with: settings.string(forKey: "maxResults")!)
        searchUrl = searchUrl.replacingOccurrences(of: "<age>", with: settings.string(forKey: "ageResults")!)
        searchUrl = searchUrl.replacingOccurrences(of: "<distance>", with: settings.string(forKey: "distanceResults")!)
        
        Alamofire.request(searchUrl).responseJSON { response in
            if let JSON = response.result.value as? [String: Any], let results = JSON["jobs"] as? [[String: Any]] {
                self.jobsAll = results
                self.switchJobSite(sender: nil)
            }
        }
        
    }
    
}
