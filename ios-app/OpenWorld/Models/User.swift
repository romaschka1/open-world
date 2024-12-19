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
    var password: String
    var emoji: String
}

struct UserLoginPayload: Encodable {
    var name: String
    var password: String
}
