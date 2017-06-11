//
//  tips.swift
//  jobagent
//
//  Created by Brenden West on 4/4/17.
//
//

import UIKit
import Alamofire

class Tips: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet
    var tableView: UITableView?
    var items = [[String: Any?]]()

  override func viewDidLoad() {
    super.viewDidLoad()
    getJSON()
  }

  
  func getJSON() {
    Alamofire.request("http://brisksoft.us/jobagent/tips.json").responseJSON { response in
      if let JSON = response.result.value as? [String: Any], let tips = JSON["Tips"] as? [[String: Any]] {
        self.items = tips
        self.tableView?.reloadData()
      }
    }
  }

  @available(iOS 2.0, *)
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
    
    let item = items[indexPath.row]
    cell.textLabel?.text = item["title"] as? String
    cell.detailTextLabel?.text = item["description"] as? String
    cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
    
    return cell
  }

  @available(iOS 2.0, *)
  func tableView(_ tableView: UITableView, titleForHeaderInSection: Int) -> String? {
    return "Latest news & tips"
  }

  @available(iOS 2.0, *)
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let link = items[indexPath.row]["link"] as? String, !link.isEmpty {
        UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil)
    }
  }

}
