//
//  Post.swift
//  HT_2
//
//  Created by Пермяков Андрей on 12.02.2024.
//

import Foundation
import RealmSwift

struct Post: Hashable, Codable {
    let imageUrl: URL?
    let rating: Int
    let title: String
    let domain: String
    let author: String
    let createdTime: TimeInterval
    let comments: Int
    let name: String
    let id: String
    let url: URL
    
    var saved: Bool
    
    var isUpvoted: Bool {
        rating >= 0
    }
    
    var time: TimeInterval {
        Date().timeIntervalSince1970 - createdTime
    }
    
    init?(from managedObject: PostObject) {
        guard let url = URL(string: managedObject.url) else { return nil }
        self.url = url
        self.imageUrl = URL(string: managedObject.imageUrl)
        self.rating = managedObject.rating
        self.title = managedObject.title
        self.domain = managedObject.domain
        self.author = managedObject.author
        self.createdTime = managedObject.createdTime
        self.comments = managedObject.comments
        self.name = managedObject.name
        self.saved = true
        self.id = managedObject.id
    }
    
    init?(from postData: PostData?) {
        guard let data = postData else { return nil }
        self.saved = false
        self.imageUrl = Post.format(url: data.stringURL ?? "")
        self.rating = data.ups + data.downs
        self.title = data.title
        self.domain = data.domain
        self.author = data.author
        self.createdTime = data.created
        self.comments = data.numComments
        self.name = data.name
        self.url = data.url
        self.id = data.id
    }
    
    private static func format(url: String) -> URL? {
        URL(string: url.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">"))
    }
    
    public func managedObject() -> PostObject {
        PostObject(with: self)
    }
}

final class PostObject: Object {
    @objc dynamic var imageUrl: String = ""
    @objc dynamic var rating: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var domain: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var createdTime: TimeInterval = 0.0
    @objc dynamic var comments: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var id: String = ""
    
    fileprivate convenience init(with post: Post) {
        self.init()
        self.imageUrl = post.imageUrl?.absoluteString ?? ""
        self.rating = post.rating
        self.title = post.title
        self.domain = post.domain
        self.author = post.author
        self.createdTime = post.createdTime
        self.comments = post.comments
        self.name = post.name
        self.url = post.url.absoluteString
        self.id = post.id
    }
}

extension Post: Equatable {
    static func ==(lhs: Post, rhs: Post) -> Bool {
        lhs.url == rhs.url
    }
}

extension Post: Comparable {
    static func < (lhs: Post, rhs: Post) -> Bool {
        lhs.title < rhs.title
    }
}
