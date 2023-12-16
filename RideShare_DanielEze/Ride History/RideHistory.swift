//
//  RideHistory.swift
//  RideShare_DanielEze
//
//  Created by Daniel Eze on 2023-12-15.
//  Copyright © 2023 Daniel Eze. All rights reserved.
//

import Foundation

struct RideHistory: Identifiable {
    var id = UUID()
    var driver: String
    var price: String
}
