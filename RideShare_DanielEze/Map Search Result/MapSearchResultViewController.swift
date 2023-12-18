//
//  MapSearchResultViewController.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-17.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapSearchResultViewController: UIViewController {
    private lazy var searchResults: [MKMapItem] = []

    private let locationManager = LocationManager.shared

    private lazy var mapSearchVC: RideSharerViewController? = nil

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.useAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ResultCell.self, forCellReuseIdentifier: ResultCell.description())
        return tableView
    }()

    private lazy var searchCompleter: MKLocalSearchCompleter = {
        let search = MKLocalSearchCompleter()
        search.delegate = self
        search.region = .init(.world)
        search.resultTypes = [.address, .pointOfInterest]
        return search
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        layout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchResults = []
        tableView.reloadData()
    }

    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func layout() {
        view.backgroundColor = .white
        view.addSubview(tableView)

        let margins = view.layoutMarginsGuide
        let constraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func updatemapSearchVC(using vc: RideSharerViewController) {
        mapSearchVC = vc
    }

    func updateSearchResults(using results: [MKMapItem]) {
        searchResults = results
        tableView.reloadData()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyBoardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardSize.height, right: 0)
        tableView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.transform = .identity
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension MapSearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.description(), for: indexPath) as! ResultCell
        let title = searchResults.lazy[indexPath.row].name ?? ""
        let subtitle = searchResults.lazy[indexPath.row].placemark.title ?? " "

        DispatchQueue.main.async {
            cell.setData(title, subtitle)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapSearchVC?.didSelectResult(result: searchResults.lazy[indexPath.row])

        DispatchQueue.main.async { [weak self] in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ResultCell.size.height
    }

}

extension MapSearchResultViewController: MKLocalSearchCompleterDelegate { }
