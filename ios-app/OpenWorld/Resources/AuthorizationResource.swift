//
//  Auth.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import Foundation

class AuthorizationResource {
    
    static let shared = AuthorizationResource()
    private var session: URLSession

    private init() {
       let config = URLSessionConfiguration.default
       config.protocolClasses = [ApiInterceptor.self]
       session = URLSession(configuration: config)
    }

    func login(_ payload: UserLoginPayload, completion: @escaping (Result<AuthorizationTokens, Error>) -> Void) {
        var request = URLRequest(url: URL(string: API.baseURL + "authorization/login")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(payload)
            request.httpBody = jsonData
        } catch {
            completion(.failure(URLError(.cannotDecodeContentData)))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode(AuthorizationTokens.self, from: data)
                storeTokens(tokens: response)

                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchRefreshToken(completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: URL(string: API.baseURL + "authorization/refresh")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        do {
            let tokens = AuthorizationTokens(
                accessToken: fetchTokenFromKeychain(key: "AccessToken"),
                refreshToken: fetchTokenFromKeychain(key: "RefreshToken")
            )
            let jsonData = try JSONEncoder().encode(tokens)
            request.httpBody = jsonData
        } catch {
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error refreshing token: \(error)")
                completion(false)
                return
            }
            
            do {
                let newTokens = try JSONDecoder().decode(AuthorizationTokens.self, from: data!)
                storeTokens(tokens: newTokens)
                completion(true)
            } catch {
                completion(false)
                return
            }
        }
        
        task.resume()
    }
}
