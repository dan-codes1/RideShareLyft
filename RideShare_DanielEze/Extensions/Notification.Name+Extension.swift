//
//  Notification.Name+Extension.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didAcceptLocation = Notification.Name("didAcceptLocationRequest")
    static let didRejectLocation = Notification.Name("didRejectLocationRequest")
    static let didUpdateLocation = Notification.Name("didUpddateLocationRequest")

}
