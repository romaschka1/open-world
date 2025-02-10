//
//  Router.swift
//  OpenWorld
//
//  Created by r on 31.01.2025.
//

import Combine
import SwiftUI

protocol Routeable: Codable, Hashable {}

enum Routes: Routeable {
    case registration
    case login
    case map
    case settings
}

@Observable class BaseRouter: ObservableObject  {
    var path = NavigationPath()
    var isEmpty: Bool {
        return path.isEmpty
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func navigate(route: Routes) {
        if (path.count != 0) {
            path.removeLast()
        }
        path.append(route)
    }
}

