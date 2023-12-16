//
//  RideHistoryViewController.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class RideHistoryViewController: UIViewController {

    private let rideHistory = [("Driver: Joe, 12/29/2021", "$26.50"),
                       ("Driver: Sandra, 01/03/2022", "$13.10"),
                       ("Driver: Hank, 01/11/2022", "$16.20"),
                       ("Driver: Michelle, 01/19/2022", "$8.50")
    ]

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.useAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RideHistoryCell.self, forCellReuseIdentifier: RideHistoryCell.description())
        tableView.contentSize = RideHistoryCell.size
        return tableView
    }()

    private lazy var titleTextView: UILabel = {
        let textView = UILabel(frame: .zero)
        textView.useAutoLayout()
        textView.text = "Ride History"
        textView.font = .preferredFont(forTextStyle: .largeTitle)
        return textView
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.useAutoLayout()
        stack.axis = .horizontal
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }

}

private extension RideHistoryViewController {
    func layout() {
        view.useAutoLayout()
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(titleTextView)

        let margins = view.layoutMarginsGuide
        let constraints: [NSLayoutConstraint] = [
            titleTextView.topAnchor.constraint(equalTo: margins.topAnchor),
            titleTextView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func createRideHistory(at index: Int) -> RideHistory {
        let driver = rideHistory[index].0
        let price = rideHistory[index].1
        let rideHistory = RideHistory(driver: driver, price: price)
        return rideHistory
    }

    func showAlert(using rideHistory: RideHistory) {
        let alert = UIAlertController(title: rideHistory.driver,
                                      message: rideHistory.price,
                                      preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

extension RideHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rideHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RideHistoryCell.description(), for: indexPath) as! RideHistoryCell
        let rideHistory = createRideHistory(at: indexPath.row)
        cell.setData(using: rideHistory)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(using: createRideHistory(at: indexPath.row))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        RideHistoryCell.size.height
    }

}
