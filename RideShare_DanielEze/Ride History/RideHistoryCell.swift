//
//  RideHistoryCell.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import UIKit

class RideHistoryCell: UITableViewCell {

    static let size: CGSize = .init(width: UIScreen.main.bounds.width * 0.8, height: 60)

    func setData(using history: RideHistory) {
        driver.text = history.driver
        price.text = history.price
        setNeedsLayout()
    }

    private lazy var driver: UILabel = {
        let textView = UILabel(frame: .zero)
        textView.useAutoLayout()
        textView.textAlignment = .natural
        textView.textColor = .black
        textView.font = .preferredFont(forTextStyle: .headline)
        return textView
    }()

    private lazy var price: UILabel = {
        let textView = UILabel(frame: .zero)
        textView.textColor = .gray
        textView.useAutoLayout()
        textView.textAlignment = .natural
        textView.font = .preferredFont(forTextStyle: .footnote)
        return textView
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.useAutoLayout()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        layout()
    }

    func layout() {
        addSubview(stackView)
        stackView.addArrangedSubview(driver)
        stackView.addArrangedSubview(price)
        
        let constraints: [NSLayoutConstraint] = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
