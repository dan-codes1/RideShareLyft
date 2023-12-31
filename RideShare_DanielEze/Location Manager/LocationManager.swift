//
//  LocationManager.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
    private let manager = CLLocationManager()
    private (set) var location: CLLocation?

    static let shared = LocationManager()

    private override init() {
        super.init()
        configure()
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    var authorizationDenied: Bool {
        (manager.authorizationStatus == .denied) || (manager.authorizationStatus == .restricted)
    }

    var coordinate: CLLocationCoordinate2D? {
        location?.coordinate
    }

    func requestLocation() {
        DispatchQueue.main.async { [weak self] in
            self?.manager.requestAlwaysAuthorization()
        }
    }

//    func checkAuthStatus() {
//        let authStatus = manager.authorizationStatus
//        switch authStatus {
//            case .authorizedWhenInUse:
//                manager.startUpdatingLocation()
//                break
//                
//            case .restricted, .denied:
//                NotificationCenter.default.post(name: .didRejectLocationRequestRequest, object: nil)
//                break
//                
//            case .notDetermined:
//                manager.requestAlwaysAuthorization()
//                break
//
//            case .authorizedAlways:
//                manager.startUpdatingLocation()
//
//            default:
//                break
//        }
//    }
}

private extension LocationManager {
    func configure() {
        manager.delegate = self
    }

    func updateLocation(using location: CLLocation) {
        if let currLocation = self.location {
            guard (absDifferenceInLatitude(currLocation.coordinate, location.coordinate) > 0.01) || (absDifferenceInLongitude(currLocation.coordinate, location.coordinate) > 0.01) else {
                return
            }
            self.location = location
            NotificationCenter.default.post(name: .didUpdateLocation, object: nil)
        } else {
            self.location = location
            NotificationCenter.default.post(name: .didUpdateLocation, object: nil)
        }
    }

    func absDifferenceInLatitude(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> Double {
        abs(coordinate1.latitude - coordinate2.latitude)
    }

    func absDifferenceInLongitude(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> Double {
        abs(coordinate1.longitude - coordinate2.longitude)
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                
            case .restricted, .denied:
                manager.requestAlwaysAuthorization()
                NotificationCenter.default.post(name: .didRejectLocationRequestRequest, object: nil)
                
            case .notDetermined:
                manager.requestAlwaysAuthorization()

            case .authorizedAlways:
                manager.startUpdatingLocation()

            default:
                manager.startUpdatingLocation()
                break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            updateLocation(using: location)
        }
    }

}
