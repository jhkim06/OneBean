//
//  LocationProvider.swift
//  OneBean
//
//  Created by Junho Kim on 2023/04/10.
//

import UIKit
import CoreLocation

class LocationProvider: NSObject, CLLocationManagerDelegate {

    private let locationManager : CLLocationManager
    
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
}
