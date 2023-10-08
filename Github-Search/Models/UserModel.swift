//
//  UserModel.swift
//  Github-Search
//
//  Created by Dhananjay Chhabra on 08/10/23.
//

import Foundation

struct UserModel: Codable{
    let login: String?
    let avatar_url: String?
    let followers_url: String?
    let location: String?
    let name: String?
    let public_repos: Int?
    let public_gists: Int?
    let followers: Int?
    let updated_at: String?
}
