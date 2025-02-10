//
//  SettingsView.swift
//  OpenWorld
//
//  Created by r on 10.02.2025.
//

import SwiftUICore
import SwiftUI

struct SettingsView: View {
    @AppStorage("loggedUser") private var loggedUserData: Data?
    @EnvironmentObject private var router: BaseRouter

    var body: some View {
        VStack {
            Button(action: {
                logout()
            }) {
                Text("Logout")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    private func logout() {
        loggedUserData = nil
        router.navigate(route: Routes.login)
    }
}
