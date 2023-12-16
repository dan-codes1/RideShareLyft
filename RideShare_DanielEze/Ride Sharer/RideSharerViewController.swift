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
        label.text = "Ride Sharer 🚙"
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()

    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.useAutoLayout()
        return stackView
    }()

    private lazy var mapView: MKMapView = {
        let view: MKMapView = MKMapView(frame: .zero)
        view.useAutoLayout()
        view.showsUserLocation = true
        view.showsCompass = true
        view.isZoomEnabled =  true
        view.delegate = self
        view.layer.cornerRadius = 10
        return view
    }()

    private lazy var rideHistoryButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.useAutoLayout()
        button.setTitle("History 🕗", for: .normal)
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
        let ok = UIAlertAction(title: "Go to settings", style: .default, handler: { [weak self] _ in
            self?.locationManager.takeUserToSettingsPage()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let alert = UIAlertController(title: "Location Needed", message: "We need your location to book a ride", preferredStyle: .alert)
        alert.addAction(ok)
        alert.addAction(cancel)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }

    @objc func didUpdateLocation() {
        guard let location = locationManager.location else { return }
        let region = MKCoordinateRegion(center: location,
                                        span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(region, animated: true)
        }
    }

    func layout() {
        view.backgroundColor = .white
        view.addSubview(titleStack)
        view.addSubview(mapView)
    
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(UIView())
        titleStack.addArrangedSubview(rideHistoryButton)

        let margins = view.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            titleStack.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20),
            titleStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
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
        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }
        let annotation = MKPointAnnotation()
        annotation.title = "You're here!"
        annotation.coordinate = userLocation.coordinate

        DispatchQueue.main.async {
            mapView.addAnnotation(annotation)
        }
    }

}
