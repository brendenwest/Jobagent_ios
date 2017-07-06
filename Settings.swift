//
//  Settings.swift
//  jobagent
//
//  Created by Brenden West on 7/5/17.
//
//

import UIKit

@objc internal class Settings : NSObject {

    class func onLaunch() {
        
        let newDefaults = UserDefaults.standard
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            newDefaults.set(countryCode, forKey: "countryCode")
            newDefaults.synchronize()
        }
    }
    
    static var searches = UserDefaults.standard.array(forKey: "searches") as? [String] ?? [String]()
    
}
