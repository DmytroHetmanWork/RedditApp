//
//  AuthModel.swift
//  RedditRead
//
//  Created by Dmytro Hetman on 22.03.2024.
//

import Foundation

struct LoginModel: Codable {
    let email: String
    let password: String
}

struct SignUpModel: Codable {
    let firstname: String
    let lastname: String
    let email: String
    let password: String
}
