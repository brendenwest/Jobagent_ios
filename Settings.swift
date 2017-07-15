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
        }

        // register defaults from bundle
        if Bundle.main.path(forResource: "Settings", ofType: "bundle") != nil, let path = Bundle.main.path(forResource: "Root", ofType: "plist"), let settings = NSDictionary(contentsOfFile: path) as? [String: Any] {
            
            var defaultsToRegister = [String:Any]()
            
            let preferences = settings["PreferenceSpecifiers"] as! [[String:Any]]

            for spec in preferences {
                if let key = spec["Key"], newDefaults.object(forKey: key as! String) == nil {
                    defaultsToRegister["key"] = spec["DefaultValue"]
                }
                
            }
                
            newDefaults.register(defaults: defaultsToRegister)
                    
            
        }
        newDefaults.synchronize()
    }
    
    static func loadConfiguration() -> [String:Any] {
        
        if let path = Bundle.main.path(forResource: "appconfig", ofType: "plist"), var config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            
            let userDefaults = UserDefaults.standard

            for key in config.keys {
                if config[key] == nil && userDefaults.object(forKey: key) != nil {
                    config[key] = userDefaults.object(forKey: key)
                } else {
                    userDefaults.set(config[key], forKey: key)
                }
            }
            userDefaults.synchronize()
            return config
            
        }
        return [:]
    }
    
    
    static var searches = UserDefaults.standard.array(forKey: "searches") as? [String] ?? [String]()
    
}
