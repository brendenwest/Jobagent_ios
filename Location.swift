//
//  Location.swift
//  jobagent
//
//  Created by Brenden West on 7/4/17.
//
//

import UIKit
import CoreLocation

@objc internal class Location : NSObject {
    
    static var defaultLocation : [String: String] {
        get {
            var place = [String:String]()
            if let zip = UserDefaults.standard.string(forKey: "zip") {

                place["city"] = UserDefaults.standard.string(forKey: "city") ?? ""
                place["state"] = UserDefaults.standard.string(forKey: "state") ?? ""
                place["country"] = UserDefaults.standard.string(forKey: "country") ?? ""
                place["postalCode"] = zip
                
            } else {
                place["postalCode"] = ""
                place["country"] = "US"
            }
            return place
            
        }
        set(newLocation) {
            UserDefaults.standard.setValue(newLocation["city"], forKey: "city")
            UserDefaults.standard.setValue(newLocation["state"], forKey: "state")
            UserDefaults.standard.setValue(newLocation["country"], forKey: "country")
            UserDefaults.standard.setValue(newLocation["zip"], forKey: "zip")
        }
    }
    
    class func getDefaultLocation() -> [String: String] {
        // temp workaround for objective-c
        return defaultLocation
    }
    
    class func updateLocation(_ place: CLPlacemark) -> [String: String] {
        // temp workaround for objective-c
        
        var newLocation = [String:String]()
        newLocation["city"] = place.locality ?? ""
        newLocation["state"] = place.administrativeArea ?? ""
        newLocation["country"] = place.isoCountryCode ?? ""
        newLocation["postalCode"] = place.postalCode
        
        self.defaultLocation = newLocation

        return newLocation
    }
    
    class func isValidZip(_ entry: String) -> Bool {
        if let zip = Int(entry), zip > 9999, zip < 100000 {
            return true
        }
        return false
    }
    
}
