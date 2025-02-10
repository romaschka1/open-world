//
//  RegisterView.swift
//  OpenWorld
//
//  Created by r on 06.02.2025.
//

import Foundation
import SwiftUI
import Combine

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    
    @AppStorage("loggedUser") private var loggedUserData: Data?

    @EnvironmentObject private var router: BaseRouter
    
    @State private var isEmojiPickerVisible: Bool = false
    let emojis = ["😀", "😎", "🤩", "🥳", "😍", "🤔", "🙃", "😴", "🥺", "😡", "🚀", "🌈", "🍕", "🎉", "❤️", "🔥"]
    
    func isRegisterButtonEnabled() -> Bool {
        return viewModel.isNameValid &&
            !viewModel.isCheckingUsername &&
            viewModel.emoji.count > 0 &&
            !viewModel.password.isEmpty
    }

    var body: some View {
        VStack {
            Text("Registration")
                .font(.largeTitle)
                .padding()

            TextField("Name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
               TextField("Select an emoji", text: $viewModel.emoji)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                   .disabled(true)
               
               Button(action: {
                   isEmojiPickerVisible.toggle()
               }) {
                   Text("Pick Emoji")
                       .font(.subheadline)
                       .foregroundColor(.white)
                       .padding(8)
                       .background(Color.blue)
                       .cornerRadius(8)
               }
            }
            .padding()

            if isEmojiPickerVisible {
               LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                   ForEach(emojis, id: \.self) { emoji in
                       Button(action: {
                           viewModel.emoji = emoji
                           isEmojiPickerVisible = false
                       }) {
                           Text(emoji)
                               .font(.system(size: 30))
                               .padding()
                               .background(Color.gray.opacity(0.2))
                               .cornerRadius(8)
                       }
                   }
               }
               .padding()
            }
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.registration { result in
                    switch result {
                        case .success(let tokens):
                            loggedUserData = encodeUser(createUserFromToken(tokens: tokens)!)
                            router.navigate(route: Routes.map)
                            
                        case .failure(let error):
                            print("Registration failed: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if viewModel.isCheckingUsername {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(8)
            .padding()
            .disabled(!self.isRegisterButtonEnabled())
            .opacity(self.isRegisterButtonEnabled() ? 1 : 0.5)
            
            Button(action: {router.navigate(route: Routes.login)}) {
               Text("Already have an account? Login")
                   .font(.subheadline)
                   .foregroundColor(.blue)
                   .padding()
           }
        }
        .padding()
    }
}

class RegistrationViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            isNameValid = false
            debounceUsernameCheck()
        }
    }
    @Published var isNameValid: Bool = false
    @Published var isCheckingUsername: Bool = false
    
    @Published var emoji = ""
    @Published var password = ""
    
    private var usernameCheckTimer: Timer?

    private func debounceUsernameCheck() {
        if (self.name == "") {
            return
        }
  
        self.isCheckingUsername = true
        // Refresh timer
        usernameCheckTimer?.invalidate()
        usernameCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            AuthorizationResource.shared.isNameUnique(self.name) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        self.isNameValid = value
                        self.isCheckingUsername = false
                    case .failure(let error):
                        self.isNameValid = false
                        self.isCheckingUsername = false
                        print("Error when validating name: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()

    func registration(completion: @escaping (Result<AuthorizationTokens, Error>) -> Void) {
        if !name.isEmpty && !password.isEmpty && !emoji.isEmpty {
            let payload = UserRegisterPayload(
                name: name,
                emoji: emoji,
                password: password)

            AuthorizationResource.shared.register(payload) { result in
                completion(result)
            }
        } else {
            let error = NSError(domain: "RegisterError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
            completion(.failure(error))
        }
    }
}
