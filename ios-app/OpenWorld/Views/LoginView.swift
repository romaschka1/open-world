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
    
    @Binding var isLoggedIn: Bool

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
                viewModel.login { user in
                    isLoggedIn = true;
                    loggedUserData = encodeUser(user)
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
        }
        .padding()
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""

    private var cancellables = Set<AnyCancellable>()

    func login(completion: @escaping (User) -> Void) {
        if !username.isEmpty && !password.isEmpty {
            let payload = UserLoginPayload(name: username, password: password)

            AuthorizationResource.shared.login(payload) { user in
                completion(user)
            }
        } else {
            print("Login failed: Invalid credentials")
        }
    }
}
