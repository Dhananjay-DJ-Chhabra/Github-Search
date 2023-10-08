//
//  SearchResult.swift
//  Github-Search
//
//  Created by Dhananjay Chhabra on 08/10/23.
//

import Foundation


struct SearchResult: Codable{
    var total_count : Int?
    var items: [Item]?
}

struct Item: Codable{
    let login: String?
    let avatar_url: String?
}
