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
    
    func register(_ payload: UserRegisterPayload, completion: @escaping (Result<AuthorizationTokens, Error>) -> Void)
    {
        var request = URLRequest(url: URL(string: API.baseURL + "authorization/register")!)
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

    func login(_ payload: UserLoginPayload, completion: @escaping (Result<AuthorizationTokens, Error>) -> Void)
    {
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
    
    func isNameUnique(_ name: String, completion: @escaping (Result<Bool, Error>) -> Void) {
       var urlComponents = URLComponents(string: API.baseURL + "authorization/isNameUnique")!

       urlComponents.queryItems = [
           URLQueryItem(name: "newName", value: String(name))
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
               let result = try decoder.decode(Bool.self, from: data)
               completion(.success(result))
           } catch {
               completion(.failure(NetworkError.decodingError(error)))
           }
       }
       
       task.resume()
    }
}
