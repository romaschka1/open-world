//
//  Authorization.swift
//  OpenWorld
//
//  Created by r on 18.12.2024.
//

import Foundation
import JWTDecode

func getLoggedUser() -> User? {
    guard let userData = UserDefaults.standard.data(forKey: "loggedUser") else {
        return nil
    }
    return decodeUser(from: userData)
}

func encodeUser(_ user: User) -> Data? {
    let encoder = JSONEncoder()
    do {
        let encoded = try encoder.encode(user)
        return encoded
    } catch {
        print("Error encoding user: \(error)")
        return nil
    }
}

func decodeUser(from data: Data) -> User? {
    let decoder = JSONDecoder()

    do {
        let decodedUser = try decoder.decode(User.self, from: data)
        return decodedUser
    } catch {
        print("Error decoding user: \(error)")
        return nil
    }
}

func createUserFromToken(tokens: AuthorizationTokens) -> User? {
    do {
        let jwt = try decode(jwt: tokens.refreshToken)
        guard let id = jwt.claim(name: "id").string,
              let name = jwt.claim(name: "name").string,
              let emoji = jwt.claim(name: "emoji").string else {
            print("Required claims are missing in the token")
            return nil
        }
        return User(id: Int(id)!, name: name, emoji: emoji)
    } catch {
        print("Error decoding token: \(error.localizedDescription)")
        return nil
    }
}
