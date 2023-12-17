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
    private var isSearching = false

    private let locationManager = LocationManager.shared

    private lazy var resultVC = MapSearchResultViewController()

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

    private lazy var searchVC: UISearchController = {
        let search = UISearchController(searchResultsController: resultVC)
        search.view.backgroundColor = .white
        search.searchResultsUpdater = self
        search.delegate = self
        search.showsSearchResultsController = true
        search.searchBar.placeholder = "Where do you want to go to?"
        return search
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
        configure()
        layout()
    }

    func searchForLocation(using term: String) async -> [MKMapItem] {
        guard term.isEmpty == false else { return [] }

        let request = MKLocalSearch.Request()
        if let location = locationManager.location {
            request.region = .init(center: location.coordinate,
                                   latitudinalMeters: 30000,
                                   longitudinalMeters: 30000
            )
        }
        request.naturalLanguageQuery = term
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            return response.mapItems
        } catch {
            print(error.localizedDescription)
        }
        return []
    }

    func didSelectResult(result: MKMapItem) {
        searchVC.searchBar.text = ""

        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }

        let directionRequest = MKDirections.Request()
        directionRequest.source = .init(placemark: .init(coordinate: locationManager.coordinate ?? result.placemark.coordinate))
        directionRequest.destination = result
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        let directions = MKDirections(request: directionRequest)

        DispatchQueue.main.async { [weak self] in
            self?.mapView.addAnnotation(result.placemark)
        }

        Task { [weak self] in
            do {
                let response = try await directions.calculate()
                await MainActor.run {
                    for route in response.routes {
                        self?.mapView.addOverlay(route.polyline)
                        self?.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    print(error)
                }
            }
        }
    }
}

private extension RideSharerViewController {
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLocationAlert), name: .didRejectLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation), name: .didUpdateLocation, object: nil)

        navigationItem.titleView = titleStack
        navigationItem.searchController = searchVC

        locationManager.checkAuthStatus()
        resultVC.updatemapSearchVC(using: self)
    }

    func takeUserToSettingsPage() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func layout() {
        view.backgroundColor = .white
        view.addSubview(mapView)
    
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(UIView())
        titleStack.addArrangedSubview(rideHistoryButton)
        let margins = view.layoutMarginsGuide
        let constraints: [NSLayoutConstraint] = [
            titleStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            mapView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            mapView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @objc func showLocationAlert() {
        let ok = UIAlertAction(title: "Go to settings", style: .default, handler: { [weak self] _ in
            self?.takeUserToSettingsPage()
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
        guard let coordinate = locationManager.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate,
                                        span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(region, animated: true)
        }
    }

    @objc func navigateToRideHistory() {
        let rideHistoryVc = RideHistoryViewController()
        DispatchQueue.main.async { [weak self] in
            self?.present(rideHistoryVc, animated: true)
        }
    }

}

extension RideSharerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}

extension RideSharerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        Task { [weak self] in
            let mapItems = await self?.searchForLocation(using: searchController.searchBar.text ?? "")
            await MainActor.run {
                self?.resultVC.updateSearchResults(using: mapItems ?? [])
            }
        }
    }

}

extension RideSharerViewController: UISearchControllerDelegate { }
