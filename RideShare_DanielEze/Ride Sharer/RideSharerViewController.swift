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
    private lazy var didHandleRegectedLocationRequest = false
    private (set) lazy var searchHistory: [MKMapItem] = []

    private let locationManager = LocationManager.shared

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.useAutoLayout()
        label.text = "Ride Share 🚙"
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()

    private lazy var rideHistoryButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.useAutoLayout()
        button.setTitle("Ride History", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(navigateToRideHistory), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.useAutoLayout()
        return stack
    }()

    private lazy var clearMapButon: UIButton = {
        let button = UIButton(frame: .zero)
        button.useAutoLayout()
        button.setTitle("Clear Map", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTapClearMap), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchHistoryButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.useAutoLayout()
        button.setTitle("Search History", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(navigateToSearchHistory), for: .touchUpInside)
        return button
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

    private lazy var resultVC: MapSearchResultViewController = {
        let vc = MapSearchResultViewController()
        vc.updatemapSearchVC(using: self)
        return vc
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
                                   latitudinalMeters: 10000,
                                   longitudinalMeters: 10000
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

    func didSelectResult(result: MKMapItem, isFromHistory: Bool = false) {
        searchVC.searchBar.text = ""
        clearMap()

        DispatchQueue.main.async { [weak self] in
            self?.mapView.addAnnotation(result.placemark)
        }
        if isFromHistory == false {
            searchHistory.append(result)
        }

        guard let location = locationManager.location else { return }

        let directionRequest = MKDirections.Request()
        directionRequest.source = .init(placemark: .init(coordinate: location.coordinate))
        directionRequest.destination = result
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        let directions = MKDirections(request: directionRequest)

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

private extension RideSharerViewController {
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(didRejectLocationRequest), name: .didRejectLocationRequestRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLocation), name: .didUpdateLocation, object: nil)

        navigationItem.leftBarButtonItem = .init(customView: titleLabel)
        navigationItem.largeTitleDisplayMode = .always

        if didHandleRegectedLocationRequest == false {
            if locationManager.authorizationDenied {
                didRejectLocationRequest()
            }
        }
    }

    func takeUserToSettingsPage() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func layout() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        view.addSubview(buttonStack)

        buttonStack.addArrangedSubview(clearMapButon)
        buttonStack.addArrangedSubview(searchHistoryButton)
        buttonStack.addArrangedSubview(rideHistoryButton)

        let margins = view.layoutMarginsGuide
        let constraints: [NSLayoutConstraint] = [
            buttonStack.topAnchor.constraint(equalTo: margins.topAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            clearMapButon.leadingAnchor.constraint(equalTo: buttonStack.leadingAnchor),

            mapView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            mapView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func clearMap() {
        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
    }

    @objc func didRejectLocationRequest() {
        if navigationItem.searchController != nil {
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 1.1, delay: 0.0, options: [.allowAnimatedContent, .beginFromCurrentState, .curveEaseInOut, .showHideTransitionViews,]) {
                    self?.navigationItem.searchController = nil
                    self?.view.layoutIfNeeded()
                } completion: { _ in }
            }
        }
        
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
                                        span: .init(latitudeDelta: 0.24, longitudeDelta: 0.24)
        )
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(region, animated: true)
        }
        if navigationItem.searchController == nil {
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [.allowAnimatedContent, .beginFromCurrentState, .curveEaseOut, .showHideTransitionViews]) {
                    self?.navigationItem.searchController = self?.searchVC
                    self?.view.layoutIfNeeded()
                } completion: { _ in
                }
            }
        }
    }

    @objc func navigateToRideHistory() {
        let rideHistoryVc = RideHistoryViewController()
        DispatchQueue.main.async { [weak self] in
            self?.present(rideHistoryVc, animated: true)
        }
    }

    @objc func navigateToSearchHistory() {
        let searchHistoryVC = SearchHistoryViewController(mapSearchVC: self)
//        searchHistoryVC.updateRideShareVC(using: self)
        DispatchQueue.main.async { [weak self] in
            self?.present(searchHistoryVC, animated: true)
        }
    }

    @objc func didTapClearMap() {
        clearMap()
        guard let coordinate = locationManager.coordinate else { return }

        let region = MKCoordinateRegion(center: coordinate,
                                        span: .init(latitudeDelta: 0.24, longitudeDelta: 0.24)
        )
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(region, animated: true)
        }
    }

}

extension RideSharerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.systemPink.withAlphaComponent(0.6)
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
