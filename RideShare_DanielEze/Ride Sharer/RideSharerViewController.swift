//
//  RideSharerViewController.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class RideSharerViewController: UIViewController {

    private let locationManager = LocationManager()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.useAutoLayout()
        label.text = "Ride Sharer"
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()

    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.useAutoLayout()
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stackView
    }()

    private lazy var mapView: MKMapView = {
        let view: MKMapView = MKMapView(frame: .zero)
        view.useAutoLayout()
        view.showsUserLocation = true
        view.showsScale = true
        view.showsCompass = false
        view.isZoomEnabled =  true
        view.delegate = self
        view.layer.cornerRadius = 10
        return view
    }()

    private lazy var rideHistoryButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.useAutoLayout()
        button.setTitle("Ride History", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(navigateToRideHistory), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
    }

}

private extension RideSharerViewController {
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLocationAlert), name: .didRejectLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation), name: .didUpdateLocation, object: nil)
        locationManager.checkAuthStatus()
    }

    @objc func showLocationAlert() {
        DispatchQueue.main.async { [weak self] in
            let ok = UIAlertAction(title: "Get location", style: .default, handler: { [weak self] _ in
                self?.locationManager.takeUserToSettingsPage()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let alert = UIAlertController(title: "Location Needed", message: "We need your location to book a ride", preferredStyle: .alert)
            alert.addAction(ok)
            alert.addAction(cancel)

            self?.present(alert, animated: true)
        }
    }

    @objc func didUpdateLocation() {
        guard let location = locationManager.location else { return }

        DispatchQueue.main.async { [weak self] in
            let region = MKCoordinateRegion(center: location,
                                            span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
            self?.mapView.setRegion(region, animated: true)
        }
    }

    func layout() {
        view.backgroundColor = .white
        view.addSubview(titleStack)
        view.addSubview(mapView)
    
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(rideHistoryButton)

        let margins = view.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            titleStack.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20),
            titleStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleStack.leadingAnchor),
            rideHistoryButton.trailingAnchor.constraint(equalTo: titleStack.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            mapView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @objc func navigateToRideHistory() {
        let rideHistoryVc = RideHistoryViewController()
        DispatchQueue.main.async { [weak self] in
            self?.present(rideHistoryVc, animated: true)
        }
    }

}
extension RideSharerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        DispatchQueue.main.async {
            for annotaion in mapView.annotations {
                mapView.removeAnnotation(annotaion)
            }
            let annotation = MKPointAnnotation()
            annotation.title = "You're here!"
            annotation.coordinate = userLocation.coordinate
            mapView.addAnnotation(annotation)
        }
    }

}
