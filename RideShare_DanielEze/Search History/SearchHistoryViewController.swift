//
//  SearchHistoryViewController.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-18.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class SearchHistoryViewController: UIViewController {

    private lazy var reideShareVC: RideSharerViewController? = nil

    var searchHistory: [MKMapItem] {
        reideShareVC?.searchHistory ?? []
    }

    private let locationManager = LocationManager.shared

    private var mapSearchVC: RideSharerViewController?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.useAutoLayout()
        label.text = "Search History 🔎 🕗"
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.useAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SearchHistoryCell.self, forCellReuseIdentifier: SearchHistoryCell.description())
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        layout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        searchResults = []
//        tableView.reloadData()
    }

    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func layout() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        let margins = view.layoutMarginsGuide
        let constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func updateRideShareVC(using vc: RideSharerViewController) {
        mapSearchVC = vc
    }

    func updateSearchHistory() {
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

}

extension SearchHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryCell.description(), for: indexPath) as! SearchHistoryCell
        let title = searchHistory.lazy[indexPath.row].name ?? ""
        let subtitle = searchHistory.lazy[indexPath.row].placemark.title ?? " "

        DispatchQueue.main.async {
            cell.setData(title, subtitle)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapSearchVC?.didSelectResult(result: searchHistory[indexPath.row])
        mapSearchVC?.didSelectResult(result: searchHistory[indexPath.row])

        DispatchQueue.main.async { [weak self] in
            tableView.deselectRow(at: indexPath, animated: true)
            self?.dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        SearchHistoryCell.size.height
    }

}
