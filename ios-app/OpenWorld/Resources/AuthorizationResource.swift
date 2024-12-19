//
//  Auth.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import Foundation

class AuthorizationResource {
    
    static let shared = AuthorizationResource()

    func login(_ payload: UserLoginPayload, completion: @escaping (User) -> Void) {
        guard let url = URL(string: API.baseURL + "authorization/login") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error authorizing user: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(user);
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
}
