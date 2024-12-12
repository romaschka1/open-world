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
    @AppStorage("loggedInUser") private var loggedInUserData: String?

    var body: some View {
        VStack {
            Text("Crete a new user")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                viewModel.login { newUser in
                    saveLoggedInUser(newUser)
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
    
    private func saveLoggedInUser(_ user: User) {
        if let jsonData = try? JSONEncoder().encode(user) {
            loggedInUserData = String(data: jsonData, encoding: .utf8)
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var username = ""
    
    private var cancellables = Set<AnyCancellable>()

    func login(completion: @escaping (User) -> Void) {
        let randomEmoji = ["😀", "🚀", "🎉", "🌟", "🔥", "🍀"].randomElement() ?? "😎"
        let newUserPayload = NewUserPayload(name: username, password: "password", emoji: randomEmoji)
        let newUser = User(id: 1, name: username, emoji: randomEmoji)
        completion(newUser)
    }
}
