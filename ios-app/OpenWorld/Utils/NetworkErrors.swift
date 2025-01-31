//
//  NetworkError.swift
//  OpenWorld
//
//  Created by r on 31.01.2025.
//

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
}
