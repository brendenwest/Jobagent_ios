//
//  Home.swift
//  jobagent
//
//  Created by Brenden West on 7/4/17.
//
//

import UIKit
import CoreLocation



extension Notification.Name {
    static let LocationUpdated = Notification.Name("locationUpdated")
}

class Home: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet var txtSearch: UITextField?
    @IBOutlet var txtLocation: UITextField?
    @IBOutlet var btnSearch: UIButton?
    @IBOutlet var lblCityState: UILabel?
    @IBOutlet var tblRecent: UITableView?
    
    var curLocation = Location.defaultLocation
    var prevLocation: String?
    
    // location detection
    var startLocation: CLLocation?
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.delegate = self
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if curLocation["postalCode"]!.isEmpty && Common.connectedToNetwork() {
            self.detectLocation()
        } else {
            self.updateLocationFields()
        }
    }
    
    func searchJobs() {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "showSearchResults", sender: nil)
    }

    @IBAction func searchButtonClicked() {
        print("searchButtonClicked")
        let enteredLocation = self.txtLocation?.text ?? ""
        
        if !Common.connectedToNetwork() {
            self.displayAlert(NSLocalizedString("STR_NO_NETWORK", comment: ""))
        }
        else if enteredLocation.isEmpty || (self.txtSearch?.text?.isEmpty)! || (Int(enteredLocation) != nil && !Location.isValidZip(enteredLocation)) {
            self.displayAlert(NSLocalizedString("STR_EMPTY_FIELD", comment: ""))
        }
        else {
            self.view.window?.endEditing(true)
            if enteredLocation == self.prevLocation {
                self.performSegue(withIdentifier: "showSearchResults", sender: nil)
            } else { // get new location placemark
                
                NotificationCenter.default.addObserver(self, selector:  #selector(self.searchJobs), name: Notification.Name.LocationUpdated, object: nil)
                
                let geocoder = CLGeocoder()
                
                // forward geocode to get address location
                geocoder.geocodeAddressString(enteredLocation, completionHandler: {[weak self] placemarks,error in
                    print("1 \(placemarks)")
                    if (error != nil) || (placemarks?.isEmpty)! {
                        // error handling
                    } else if placemarks?.count == 1, let coordinate = placemarks!.first?.location?.coordinate {
                        
                        // get postal code for placemark
                        print("2 ")
                        let location = CLLocation.init (latitude: coordinate.latitude, longitude: coordinate.longitude)
                        geocoder.reverseGeocodeLocation(location, completionHandler: {
                            newPlacemarks, error in
                            if (error != nil) || (placemarks?.isEmpty)! {
                            } else {
                                self?.geocodeHandler(newPlacemarks!)
                            }
                        })
                    } else {
                        print("2b ")
                        self?.geocodeHandler(placemarks!)
                    }
                })
             }
        }
    }
    
    func geocodeHandler(_ placemarks: [CLPlacemark]) {
        if placemarks.count == 1 {
            print("3 \(placemarks)")
            self.curLocation = Location.updateLocation(placemarks.first!)
            
            self.updateLocationFields()
            
            // notify search method
            NotificationCenter.default.post(name: Notification.Name.LocationUpdated, object: self)

        } else {
            print("2b ")
            self.performSegue(withIdentifier: "showCities", sender: placemarks)
        }
    }

    func displayAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchResults" {
            // TK: save search
            
            if let vc = segue.destination as? SearchResults {
                vc.keyword = self.txtSearch!.text!
                vc.location = self.txtLocation!.text!
                vc.locale = curLocation["country"]!
            }
        } else if segue.identifier == "showCities" {
            // TK: show cities
        }
    }
    
    // MARK: Location methods
    
    func detectLocation() {
        print("detectLocation")
        if CLLocationManager.locationServicesEnabled() {
            print("locationServicesEnabled")
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location check failed w/ \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let newLocation: CLLocation = locations.last!
        if startLocation == nil || (startLocation?.horizontalAccuracy)! > newLocation.horizontalAccuracy {
            startLocation = newLocation
            if newLocation.horizontalAccuracy <= manager.desiredAccuracy {
                locationManager.stopUpdatingLocation()
                self.performCoordinateGeocode(newLocation)
            }
        }
        
    }
    
    func performCoordinateGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
        [weak self] placemarks, error in
            if (error != nil) || (placemarks?.isEmpty)! {
                print(error ?? "")
            }
            self?.geocodeHandler(placemarks!)
        })
    }
    
    func updateLocationFields() {
        
        self.lblCityState?.isHidden = curLocation["country"] != "US"
        self.lblCityState?.text = "\(curLocation["city"]!), \(curLocation["state"]!)"
        self.txtLocation?.text = curLocation["postalCode"]
        
    }
    
    // MARK: TableView methods
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    // MARK: TextView methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtLocation {
            self.prevLocation = textField.text
        }
    }
    
}
