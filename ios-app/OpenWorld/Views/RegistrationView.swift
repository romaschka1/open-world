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
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding()
            }
            
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
    @Published var name = ""
    @Published var emoji = ""
    @Published var password = ""

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
