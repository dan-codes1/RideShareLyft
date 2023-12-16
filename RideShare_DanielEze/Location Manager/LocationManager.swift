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
    private let locationManager = CLLocationManager()
    private (set) var location: CLLocationCoordinate2D?
    private (set) var adress: CLLocation?

    override init() {
        super.init()
        self.location = nil
        self.adress = nil
        configure()
    }

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    func takeUserToSettingsPage() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func requestLocation() {
        DispatchQueue.main.async { [weak self] in
            self?.locationManager.requestAlwaysAuthorization()
        }
    }

    func checkAuthStatus() {
        let authStatus = locationManager.authorizationStatus
        switch authStatus {
            case .authorizedWhenInUse:
                locationManager.startMonitoringSignificantLocationChanges()
                break
                
            case .restricted, .denied:
                NotificationCenter.default.post(name: .didRejectLocation, object: nil)
                break
                
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                break

            case .authorizedAlways:
                locationManager.startMonitoringSignificantLocationChanges()

            default:
                break
        }
    }
}

private extension LocationManager {
    func configure() {
        locationManager.delegate = self
        locationManager.distanceFilter = 2500
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse:
                manager.startMonitoringSignificantLocationChanges()
                break
                
            case .restricted, .denied:
                NotificationCenter.default.post(name: .didRejectLocation, object: nil)
                break
                
            case .notDetermined:
                manager.requestAlwaysAuthorization()
                break

            case .authorizedAlways:
                manager.startMonitoringSignificantLocationChanges()

            default:
                manager.startMonitoringSignificantLocationChanges()
                break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        adress = locations.first
        NotificationCenter.default.post(name: .didUpdateLocation, object: nil)
    }

}
