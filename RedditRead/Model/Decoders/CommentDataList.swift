//
//  CommentDataList.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 18.04.2024.
//

import Foundation

struct CommentDataList: Decodable {
    var commentsData = [CommentData]()
    enum CodingKeys: String, CodingKey {
        case comments = "children"
        
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        
        commentsData = try data.decode([CommentData].self, forKey: .comments)
    }
}
