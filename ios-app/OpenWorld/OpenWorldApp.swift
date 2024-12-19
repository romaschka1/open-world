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

    var body: some Scene {
       WindowGroup {
           VStack {
               if isAuthorizedUser {
                   MapRepresentable()
                       .edgesIgnoringSafeArea(.all)
               } else {
                   LoginView(isLoggedIn: $isAuthorizedUser)
               }
           }
           .onAppear {
               isAuthorized { authorized in
                   isAuthorizedUser = authorized
               }
           }
        }
    }
}
