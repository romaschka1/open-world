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
    var emoji: String
    var password: String?
}

struct UserLoginPayload: Encodable {
    var name: String
    var password: String
}

struct UserRegisterPayload: Encodable {
    var name: String;
    var emoji: String;
    var password: String;
}
