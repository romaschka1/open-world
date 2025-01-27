//
//  UserLocation.swift
//  OpenWorld
//
//  Created by romaska on 29.11.2024.
//

import Foundation

class UserLocationResource {
    
    static let shared = UserLocationResource()
    private var session: URLSession

    private init() {
       let config = URLSessionConfiguration.default
       config.protocolClasses = [ApiInterceptor.self]
       session = URLSession(configuration: config)
    }

    func getLocations(completion: @escaping ([[UserLocation]]) -> Void) {
        var urlComponents = URLComponents(string: API.baseURL + "location")!
        guard let userId = getLoggedUser()?.id else { return }

        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: String(userId))
        ]
        
        let task = session.dataTask(with: urlComponents.url!) { data, response, error in
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
        var urlComponents = URLComponents(string: API.baseURL + "location")!
        guard let userId = getLoggedUser()?.id else { return }

        urlComponents.queryItems = [URLQueryItem(name: "userId", value: String(userId))]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(locations)
            request.httpBody = jsonData
        } catch {
            completion(false)
            return
        }

        let task = session.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }
}
