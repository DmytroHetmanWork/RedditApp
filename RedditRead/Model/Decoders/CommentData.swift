//
//  CommentData.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 18.04.2024.
//

import Foundation

struct CommentData: Decodable {
    let username: String?
    let created: Double?
    let body: String?
    let rating: Int?
    let depth: Int?
    let permalink: String?
    var replies = [CommentData]()
    
    let kind: Kind
    
    enum Kind: Equatable {
        case data, more([String])
    }
    
    enum CodingKeys: String, CodingKey {
        case created, body, depth, permalink
        case username = "author"
        case numComments = "num_comments"
        case rating = "score"
        
        case replies
        
        case data
        case children
    }
    
    init(from decoder: Decoder) throws {
        let values = try? decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try? values?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

        if ((dataContainer?.allKeys.contains(where: { $0 == .children })) ?? false) {
            let more = (try? dataContainer?.decode([String].self, forKey: .children)) ?? [String]()
            kind = .more(more)
            username = nil
            permalink = nil
            created = nil
            body = nil
            rating = nil
            depth = nil
            replies = []
        } else {
            kind = .data
            username = try dataContainer?.decodeIfPresent(String.self, forKey: .username)
            permalink = try dataContainer?.decodeIfPresent(String.self, forKey: .permalink  )
            created = try dataContainer?.decodeIfPresent(Double.self, forKey: .created)
            body = try dataContainer?.decodeIfPresent(String.self, forKey: .body)
            rating = try dataContainer?.decodeIfPresent(Int.self, forKey: .rating)
            depth = try dataContainer?.decodeIfPresent(Int.self, forKey: .depth)
            replies = (try? dataContainer?
                .decodeIfPresent(CommentDataList.self, forKey: .replies))?.commentsData ?? []
        }
    }
}
