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
    var shouldLoad = false

    var currentSearch = [String: String]()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var btnJobSites: UISegmentedControl!
    @IBOutlet weak var lblSearch: UILabel?
    @IBOutlet weak var uiLoading: UIActivityIndicatorView?

    let segueId = "showJobDetail"
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
        
        let label = NSLocalizedString("STR_RESULTS_FOR", comment: "")
        self.lblSearch?.text = "\(label) \(keyword) in \(location))"
        if self.shouldLoad {
            self.isLoading(true)
            self.loadJobs()
        }
    }
    
    func isLoading(_ state: Bool) {
        self.tableView?.isHidden = state
        self.btnJobSites?.isHidden = state
        self.uiLoading?.isHidden = !state
        if state {
            uiLoading?.startAnimating()
        } else {
            uiLoading?.stopAnimating()
            self.btnJobSites?.setEnabled(locale == "US", forSegmentAt: 2)
            self.btnJobSites?.setEnabled(locale == "US", forSegmentAt: 3)
        }
    }
    
    // MARK: TableView methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobsForSite.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let index = self.btnJobSites.selectedSegmentIndex
        
        let labelWidth = (index == 1) ? 65 : 300
        let headerView = UIControl.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25))
        let headerLabel = UILabel.init(frame: CGRect.init(x: 5, y: 5, width: labelWidth, height: 20))
        headerLabel.text = siteList[index]["displayName"]
        headerLabel.textColor = UIColor.darkGray
        headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
        let headerBorder = UIView.init(frame: CGRect.init(x: 0, y: 24, width: 320, height: 1))
        headerBorder.backgroundColor = UIColor.lightGray
        headerView.addSubview(headerLabel)
        
        if index == 1 {
            let imageRect = CGRect.init(x: labelWidth+1, y: 5, width: 54, height: 20)
            let headerImage = UIImageView.init(frame: imageRect)
            let image = UIImage.init(contentsOfFile: Bundle.main.path(forResource: "indeed_logo", ofType: "gif")!)
            headerImage.image = image
            headerImage.isOpaque = true
            headerView.addSubview(headerImage)
            headerView.addTarget(self, action: #selector(linkToSource), for: .touchUpInside)
        }
        
        headerView.addSubview(headerBorder)
        
        return headerView
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        let job = jobsForSite[indexPath.row]

        let pubdate = DateUtilities.dateStringFrom(string: job["pubdate"] as! String)
        let company = job["company"] as? String ?? ""
        let location = job["location"] as? String ?? ""
        
        cell.textLabel?.text = job["title"] as? String ?? ""
        cell.detailTextLabel?.text = "\(pubdate) ~ \(company) ~ \(location)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
         return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: segueId, sender: tableView)
        
    }

    // MARK: segue to detail
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case segueId:
            
            let detailVC = segue.destination as! JobDetail
            if (sender as? UITableView) == self.tableView {
                let job = Job(context: appDelegate.dataController.container.viewContext)
                if let indexPath = tableView?.indexPathForSelectedRow  {
                    let tmpJob = self.jobsForSite[indexPath.row]
                    job.title = tmpJob["title"] as? String
                    job.notes = tmpJob["description"] as? String
                    job.location = tmpJob["location"] as? String
                    job.link = tmpJob["link"] as? String
                    job.setValue(value: tmpJob["company"] as Any, forField: .company)

                    let pubdate = DateUtilities.dateStringFrom(string: tmpJob["pubdate"] as! String)
                    job.setValue(value: pubdate as String, forField: .date)
                    detailVC.selectedJob = job
                }
                self.shouldLoad = false
            }
            
        default:
            print("Unknown segue: \(String(describing: segue.identifier))")
        }
    }

    @IBAction func switchJobSite(sender: Any?) {
        self.tableView?.reloadData()
    }
    
    @objc func linkToSource() {
        UIApplication.shared.open(URL.init(string: siteList[self.btnJobSites.selectedSegmentIndex]["domain"]!)!, options: [:], completionHandler: nil)
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
            if let results = response.result.value as? [[String: Any]] {
                self.isLoading(false)
                self.jobsAll = results
                self.switchJobSite(sender: nil)
            }
        }
        
    }
    
}
