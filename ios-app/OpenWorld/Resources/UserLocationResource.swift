//
//  UserLocation.swift
//  OpenWorld
//
//  Created by romaska on 29.11.2024.
//

import UIKit

class UserLocationResource {
    func getLocations(completion: @escaping ([[UserLocation]]) -> Void) {
        guard let url = URL(string: API.baseURL + "location") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let locations = try decoder.decode([[UserLocation]].self, from: data)

                completion(locations)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
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
