//
//  Auth.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import Foundation

class AuthResource {

    func sendLocations(_ locations: [UserLocation], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: API.baseURL + "location") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(locations)
            request.httpBody = jsonData
        } catch {
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }
}
