//
//  PostsList.swift
//  HT_2
//
//  Created by Пермяков Андрей on 12.02.2024.
//

import Foundation

struct PostDataList: Decodable {
    var posts = [PostData]()
    enum CodingKeys: String, CodingKey {
        case posts = "children"
        
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        posts = try data.decode([PostData].self, forKey: .posts)
    }
}
