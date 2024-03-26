//
//  MoreCommentsListData.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 25.04.2024.
//

import Foundation

struct MoreCommentsListData: Decodable {
    var commentsData = [CommentData]()
    
    enum CodingKeys: String, CodingKey {
        case comments = "things"
        case data, json
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let json = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .json)
        let data = try json.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        commentsData = try data.decodeIfPresent([CommentData].self, forKey: .comments) ?? []
    }
    
}
