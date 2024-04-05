//
//  CommentModel.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 17.04.2024.
//

import Foundation

struct CommentModel: Codable, Identifiable {
    let username: String
    let timeCreated: TimeInterval
    let body: String
    let rating: Int
    let depth: Int
    var replies: [CommentModel]
    let permalink: URL

    var id: URL {
        permalink
    }
    
    var time: TimeInterval {
        timeCreated - Date().timeIntervalSince1970
    }

    mutating func add(replies: inout ArraySlice<CommentData>) {
        // Next comment is a reply to current only if its depth is greater by 1.
        // Returns if replies is empty.
        guard replies.first?.depth == (self.depth + 1) else { return }
        let reply = replies.removeFirst()
        guard var comment = CommentModel(from: reply) else { return }
        
        if let nextDepth = replies.first?.depth {
            // If depth of next comment after our reply is greater,
            // that comment is a reply to our reply, so we add it recursively.
            if nextDepth > comment.depth {
                comment.add(replies: &replies)
            }
        }
        self.replies.append(comment)
        // Recursively the rest of replies.
        add(replies: &replies)
    }
    
    init?(from commentData: CommentData) {
        guard commentData.kind == .data,
              let username = commentData.username,
              let timeCreated = commentData.created,
              let commentText = commentData.body,
              let rating = commentData.rating,
              let depth = commentData.depth,
              let stringURL = commentData.permalink,
              let permalink = URL(string: "https://www.reddit.com\(stringURL)")
        else { return nil }
        self.username = username
        self.permalink = permalink
        self.timeCreated = timeCreated
        self.body = commentText
        self.rating = rating
        self.depth = depth
        self.replies = commentData.replies.compactMap { CommentModel(from: $0) }
    }
    
    init?(body: String) {
        timeCreated = Date().timeIntervalSince1970
        self.body = body
        rating = 0
        depth = 0
        replies = []
        
        if let userEmail = Defaults.userEmail {
            username = userEmail
        } else {
            return nil
        }
        
        if let url = URL(string: "https://www.reddit.com") {
            permalink = url
        } else {
            return nil
        }
    }
}
