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

    func getLocations(_ userId: Int, completion: @escaping (Result<[[UserLocation]], Error>) -> Void) {
       var urlComponents = URLComponents(string: API.baseURL + "locations")!
       
       urlComponents.queryItems = [
           URLQueryItem(name: "userId", value: String(userId))
       ]
       
       guard let url = urlComponents.url else {
           completion(.failure(NetworkError.invalidURL))
           return
       }
       
       let task = session.dataTask(with: url) { data, response, error in
           if let error = error {
               completion(.failure(error))
               return
           }
           
           guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
               completion(.failure(NetworkError.invalidResponse))
               return
           }
           
           guard let data = data else {
               completion(.failure(NetworkError.noData))
               return
           }
           
           do {
               let decoder = JSONDecoder()
               let locations = try decoder.decode([[UserLocation]].self, from: data)
               completion(.success(locations))
           } catch {
               completion(.failure(NetworkError.decodingError(error)))
           }
       }
       
       task.resume()
    }
    
    func sendLocations(_ locations: [UserLocation], completion: @escaping (Bool) -> Void) {
        var urlComponents = URLComponents(string: API.baseURL + "locations")!
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
