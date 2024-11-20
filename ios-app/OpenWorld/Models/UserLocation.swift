//
//  UserLocation.swift
//  OpenWorld
//
//  Created by romaska on 17.11.2024.
//

import Foundation

struct UserLocation: Codable {
    let time: String  // ISO 8601 formatted date
    let latitude: Int64
    let longitude: Int64
}
