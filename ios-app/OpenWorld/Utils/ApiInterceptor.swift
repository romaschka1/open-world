//
//  ApiInterceptor.swift
//  OpenWorld
//
//  Created by r on 30.12.2024.
//

import Foundation

class ApiInterceptor: URLProtocol {
    static weak var router: BaseRouter?

    static var excludedEndpoints: [String] = [
        API.baseURL + "authorization/refresh",
        API.baseURL + "authorization/login",
        API.baseURL + "authorization/isNameUnique"
    ]
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let urlString = request.url?.absoluteString else { return false }
        
        // Skip intercepting URL if it's present in `excludedEndpoints`
        for endpoint in excludedEndpoints {
           if urlString.contains(endpoint) {
               return false
           }
        }

        return true
   }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let accessToken = fetchTokenFromKeychain(key: "AccessToken")

        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: modifiedRequest) { data, response, error in
            // Call refresh enpoint, if request is unauthorised
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                AuthorizationResource.shared.fetchRefreshToken() { success in
                    if success {
                        self.retryRequest()
                    } else {
                        self.client?.urlProtocol(self, didFailWithError: NSError(domain: "TokenRefreshFailed", code: 401, userInfo: nil))
                    }
                }
            } else if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            // Request don't have any isses
            } else {
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }

        task.resume()
    }

    override func stopLoading() {}

    // Retry the original request with the new access token
    private func retryRequest() {
        let newAccessToken = fetchTokenFromKeychain(key: "AccessToken")

        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: modifiedRequest) { data, response, error in
            if let error = error {
                // Token expires, force user to login arain
                ApiInterceptor.router?.navigate(route: Routes.login)
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }

        task.resume()
    }
}
