//
//  PostData.swift
//  HT_2
//
//  Created by Пермяков Андрей on 13.02.2024.
//

import Foundation

struct PostData: Decodable {
    var stringURL: String?
    let ups: Int
    let downs: Int
    let title: String
    let domain: String
    let author: String
    let numComments: Int
    let created: Double
    let name: String
    let id: String
    let url: URL

    enum CodingKeys: String, CodingKey {
        case thumbnail, ups, downs, title, domain, author, created, name, url, id
        case numComments = "num_comments"
        case preview
        
        case data
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
    
        ups = try dataContainer.decode(Int.self, forKey: .ups)
        downs = try dataContainer.decode(Int.self, forKey: .downs)
        domain = try dataContainer.decode(String.self, forKey: .domain)
        title = try dataContainer.decode(String.self, forKey: .title)
        author = try dataContainer.decode(String.self, forKey: .author)
        numComments = try dataContainer.decode(Int.self, forKey: .numComments)
        created = try dataContainer.decode(Double.self, forKey: .created)
        name = try dataContainer.decode(String.self, forKey: .name)
        url = try dataContainer.decode(URL.self, forKey: .url)
        id = try dataContainer.decode(String.self, forKey: .id)
        if dataContainer.allKeys.contains(where: { $0 == .preview }) {
            let preview = try dataContainer.decode(ImageURL.self, forKey: .preview)
            stringURL = preview.image?.source.url
        }
    }
}
