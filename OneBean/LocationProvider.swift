//
//  LocationProvider.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/10.
//

import UIKit
import CoreLocation
import Contacts

class LocationProvider: NSObject, CLLocationManagerDelegate {

    private let locationManager : CLLocationManager
    var completion: ((String) -> Void)?
    
    override init() {
        locationManager = CLLocationManager()
        
        super.init()
        
        locationManager.delegate = self
        locationManager.distanceFilter = 1
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("success")
        case .denied:
            print("denied")
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("updated locations: \(locations)")
        guard let location = locations.last else {return}
        print("location: \(location)")
        
        let geocoder = CLGeocoder()
        var addressStr: String!
        
        geocoder.reverseGeocodeLocation(locations.first!) { (placemarks, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let placemarks = placemarks {
                let placemark = placemarks[0]
                // Use placemark to access the address information
                if let address = placemark.postalAddress {
                    //let formatter = CNPostalAddressFormatter()
                
                    //let addressString = formatter.string(from: address)
                    //print(addressString)
                    addressStr = address.city + " " + address.street
                    self.completion!(addressStr)
                }
            }
        }
    }
    func start() {
        locationManager.startUpdatingLocation()
    }
    func getLocation()->CLLocation {
        //print("get location: \(String(describing: locationManager.location))")
        locationManager.requestLocation()
        return locationManager.location!
    }
    func getAddress(completion: @escaping (String) -> Void) {
        self.completion = completion
        //locationManager.startUpdatingLocation()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("fail with error") // need to use requestLocation()?
    }
    
}
