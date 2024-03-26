//
//  PostsProvider.swift
//  HT_2
//
//  Created by Пермяков Андрей on 14.03.2024.
//

import Foundation
import RealmSwift
import Combine

class PostsProvider {
    static var shared = PostsProvider()
    
    private let realm = try? Realm()
    
    let requestor = RedditRequestor()
    
    @Published var savedOnly = false

    var posts: [Post] {
        savedOnly ? savedPosts : loadedPosts
    }
    
    var savedPosts = [Post]()
    
    private var loadedPosts = [Post]()
    
    private init() {
        retrieveFromRealm()
    }
    
    func loadPosts(subreddit: String = "ios",
                   limit: Int = 15,
                   after: String? = nil,
                   _ completion: @escaping () -> Void) {
        requestor.makeRequest(subreddit: subreddit, limit: limit, after: after) { result in
            switch result {
            case .failure(let error):
               print("Something went wrong: \(error)")
            case .success(let data):
                let posts = data.compactMap { postData -> Post? in
                    guard var post = Post(from: postData) else { return nil }
                    post.saved = self.savedPosts.contains(where: { $0 == post })
                    return post
                }
                self.loadedPosts += posts
                completion()
            }
        }
    }
    
    // MARK: - Retrieving saved posts.
    
    func retrieveFromRealm() {
        if let postsObjects = realm?.objects(PostObject.self) {
            savedPosts = postsObjects.compactMap({ Post(from: $0) }).sorted()
        }
    }
    
    // MARK: - Saving posts.
    
    func save(_ post: Post) {
        if post.saved {
            if let index = savedPosts.firstIndex(where: { post == $0 }) {
                try! realm?.write {
                    if let objects = realm?.objects(PostObject.self) {
                        realm?.delete(objects.filter("url=%@", post.url.absoluteString))
                    }
                }
                savedPosts.remove(at: index)
            }
        } else {
            savedPosts.append(post)
            try! realm?.write {
                realm?.add(post.managedObject())
            }
            savedPosts[savedPosts.count - 1].saved.toggle()
        }
        if let index = loadedPosts.firstIndex(where: { post == $0 }) {
            loadedPosts[index].saved.toggle()
        }
        savedPosts.sort()
    }
}
