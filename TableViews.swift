//
//  Tables.swift
//  jobagent
//
//  Created by Brenden West on 6/29/17.
//
//

import UIKit

let detailWidth = CGRect(x:65.0, y:0.0, width:UIScreen.main.bounds.size.width - 80, height:44.0)

func customLabel(from cell: UITableViewCell?) -> UILabel {
    if let label = cell?.contentView.subviews[0] as? UILabel {
        return label
    }
    
    let label = UILabel.init(frame: CGRect(x:10.0, y:10.0, width:60.0, height:25.0))
    label.font = UIFont.systemFont(ofSize: 10.0)
    label.textColor = UIColor.gray
    return label
}

func customDetail(from cell: UITableViewCell?) -> UILabel {
    if let label = cell?.contentView.subviews[1] as? UILabel {
        return label
    }
    return UILabel()
}

