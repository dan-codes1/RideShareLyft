//
//  View+Extension.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    var screen: CGRect {
        UIScreen.main.bounds
    }

    func useAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }

}
