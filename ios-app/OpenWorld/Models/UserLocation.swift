//
//  Loction.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import Foundation

struct UserLocation: Codable {
    let time: String  // ISO 8601 formatted date
    let latitude: Double
    let longitude: Double
}
