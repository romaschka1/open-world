//
//  OpenWorldApp.swift
//  OpenWorld
//
//  Created by romaska on 02.09.2024.
//

import SwiftUI

@main
struct OpenWorldApp: App {
    @State private var isAuthorizedUser: Bool = false
    @State private var isLoading: Bool = true

    var body: some Scene {
       WindowGroup {
           VStack {
               if isLoading {
                   ProgressView("Logging in...").padding()
               } else if isAuthorizedUser {
                   MapRepresentable().edgesIgnoringSafeArea(.all)
               } else {
                   LoginView(isLoggedIn: $isAuthorizedUser)
               }
           }
           .onAppear {
               AuthorizationResource.shared.verifyToken() { response in
                   DispatchQueue.main.async {
                       isAuthorizedUser = response
                       isLoading = false
                   }
               }
           }
        }
    }
}
