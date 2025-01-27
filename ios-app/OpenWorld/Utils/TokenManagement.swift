//
//  TokenManagement.swift
//  OpenWorld
//
//  Created by r on 30.12.2024.
//

import Security
import Foundation

func storeTokens(tokens: AuthorizationTokens) {
    storeTokenInKeychain(key: "AccessToken", token: tokens.accessToken)
    storeTokenInKeychain(key: "RefreshToken", token: tokens.refreshToken)
}

private func storeTokenInKeychain(key: String, token: String) {
    let tokenData = token.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: tokenData
    ]

    SecItemDelete(query as CFDictionary) // Remove any existing token
    SecItemAdd(query as CFDictionary, nil) // Save the new token
}

func fetchTokenFromKeychain(key: String) -> String {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var result: AnyObject?
    if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
       let tokenData = result as? Data,
       let token = String(data: tokenData, encoding: .utf8) {
        return token
    }

    return ""
}
