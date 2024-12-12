//
//  OpenWorldApp.swift
//  OpenWorld
//
//  Created by romaska on 02.09.2024.
//

import SwiftUI

@main
struct OpenWorldApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
//            if isLoggedIn {
                MapRepresentable()
                    .edgesIgnoringSafeArea(.all)
//            } else {
//                LoginView()
//            }
        }
    }
}
