//
//  Authorization.swift
//  OpenWorld
//
//  Created by r on 18.12.2024.
//

import Foundation

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

func isAuthorized(completion: @escaping (Bool) -> Void) {
    guard let user = getLoggedUser() else {
        completion(false)
        return;
    }
    
    let payload = UserLoginPayload(name: user.name, password: user.password)
    
    AuthorizationResource.shared.login(payload) { _ in
        completion(true)
    }
}
