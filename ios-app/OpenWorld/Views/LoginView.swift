//
//  Login.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import Foundation
import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    @AppStorage("loggedUser") private var loggedUserData: Data?

    @EnvironmentObject private var router: BaseRouter

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.login { result in
                    switch result {
                        case .success(let tokens):
                            loggedUserData = encodeUser(createUserFromToken(tokens: tokens)!)
                            router.navigate(route: Routes.map)
                            
                        case .failure(let error):
                            print("Login failed: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding()
            }
            
            Button(action: {
                router.navigate(route: Routes.registration)
           }) {
               Text("Don't have an account? Register")
                   .font(.subheadline)
                   .foregroundColor(.blue)
                   .padding()
           }
        }
        .padding()
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""

    private var cancellables = Set<AnyCancellable>()

    func login(completion: @escaping (Result<AuthorizationTokens, Error>) -> Void) {
        if !username.isEmpty && !password.isEmpty {
            let payload = UserLoginPayload(name: username, password: password)

            AuthorizationResource.shared.login(payload) { result in
                completion(result)
            }
        } else {
            let error = NSError(domain: "LoginError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
            completion(.failure(error))
        }
    }
}
