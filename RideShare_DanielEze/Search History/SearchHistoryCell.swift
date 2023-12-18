//
//  SearchHistoryCell.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-18.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import UIKit

class SearchHistoryCell: UITableViewCell {

    static let size: CGSize = .init(width: UIScreen.main.bounds.width * 0.8, height: 70)

    func setData(_ title: String, _ subtitle: String = "") {
        titleLabel.text = title
        subTitleLabel.text = subtitle
        setNeedsLayout()
    }

    private lazy var titleLabel: UILabel = {
        let textView = UILabel(frame: .zero)
        textView.useAutoLayout()
        textView.textAlignment = .natural
        textView.textColor = .black
        textView.font = .preferredFont(forTextStyle: .headline)
        return textView
    }()

    private lazy var subTitleLabel: UILabel = {
        let textView = UILabel(frame: .zero)
        textView.useAutoLayout()
        textView.textAlignment = .natural
        textView.textColor = .gray
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
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
        addSubview(titleLabel)
        addSubview(subTitleLabel)

        let margin = layoutMarginsGuide

        let constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: margin.topAnchor, constant: -1),
            titleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subTitleLabel.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            subTitleLabel.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

