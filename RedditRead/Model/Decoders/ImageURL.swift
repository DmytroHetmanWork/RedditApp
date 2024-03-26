//
//  ImagesList.swift
//  HT_2
//
//  Created by Пермяков Андрей on 13.02.2024.
//

import Foundation

struct ImageURL: Decodable {
    var image: ImageUrlStringSource?
    
    enum CodingKeys: CodingKey {
        case image
        
        case images
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        image = try values.decode([ImageUrlStringSource].self, forKey: .images).first
    }
}

struct ImageUrlStringSource: Codable {
    var source: ImageUrlString
    
    struct ImageUrlString: Codable {
        var url: String
    }
}
