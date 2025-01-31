//
//  OpenWorldApp.swift
//  OpenWorld
//
//  Created by romaska on 02.09.2024.
//

import SwiftUI

@main
struct OpenWorldApp: App {
    @State private var initialLocations: [[UserLocation]] = []
    @State private var hasAppeared: Bool = false
    
    @StateObject private var router = BaseRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                VStack {
                    ProgressView().padding()
                }
                .navigationDestination(for: Routes.self) { route in
                    switch route {
                        case .login:
                            LoginView()
                                .navigationBarBackButtonHidden(true)
                        case .map:
                            MapRepresentable(locations: $initialLocations)
                                .edgesIgnoringSafeArea(.all)
                                .navigationBarBackButtonHidden(true)
                    }
                }
                .environmentObject(router)
            }
            .onAppear {
                // Perform initial navigation only once
                if !hasAppeared {
                    hasAppeared = true
                    ApiInterceptor.router = router
                    initialNavigation(router: router)
                }
            }
        }
    }

    
    private func initialNavigation(router: BaseRouter) {
        // Check if user is authorized by calling `getLocations`
        guard let userId = getLoggedUser()?.id else {
            router.navigate(route: Routes.login)
            return
        }

        UserLocationResource.shared.getLocations(userId) { result in
            switch result {
                case .success(let locations):
                    initialLocations = locations
                    router.navigate(route: Routes.map)
                    
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    router.navigate(route: Routes.login)
            }
        }
    }
}
