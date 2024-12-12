//
//  User.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import Foundation

struct User: Codable {
    var id: Int
    var name: String
    var emoji: String // Repsesenting user avatar for now
}

struct NewUserPayload {
    var name: String
    var password: String
    var emoji: String
}
