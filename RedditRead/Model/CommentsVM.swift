//
//  Comments.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 17.04.2024.
//

import SwiftUI
import Combine

class CommentsVM: ObservableObject {
    @Published var comments = [CommentModel]()
    @Published var newComment = ""

    private var more = [String]()
    
    private(set) var loadingMore = false

    private let reddit = "https://www.reddit.com/"
    private let depth = 3
    
    private let subreddit: String
    private let postId: String
    private let limit: Int
    
    init(subreddit: String, id: String, _ limit: Int = 15) {
        self.limit = limit
        self.postId = id
        self.subreddit = subreddit
        fetchComments()
    }
    
    public func tryToLoadMore(currentItem: CommentModel) {
        guard !loadingMore, shouldLoadMore(currentItem: currentItem) else { return }
        loadingMore = true
        fetchMoreComments(limit: self.limit)
    }
    
    @inline(__always)
    private func shouldLoadMore(currentItem: CommentModel) -> Bool {
        !more.isEmpty && currentItem.id == comments.last?.id
    }
    
    private func fetchComments() {
        guard let url = URL(string: "\(reddit)r/\(subreddit)/comments/\(postId).json?limit=\(limit)&depth=\(depth)")
        else { return }
        loadData(from: url) { (result: Result<[CommentDataList], Error>) in
            switch result {
            case .failure(let error):
                print("Could not load data: \(error)")
            case .success(let commentDataListArr):
                self.extractComments(from: commentDataListArr)
            }
        }
    }
    
    private func fetchMoreComments(subreddit: String = "Music",
                                   linkId: String = "t3_u5jfbi",
                                   limit: Int = 20)  {
        let range = 0..<(min(limit, more.count))
        let children = more[range].joined(separator: ",")
        more.removeSubrange(range)
        guard let url = URL(string: "\(reddit)api/morechildren.json?limit=\(limit)&depth=\(depth)&link_id=\(linkId)&api_type=json&children=\(children)")
        else { return }
        loadData(from: url) { (result: Result<MoreCommentsListData, Error>) in
            switch result {
            case .failure(let error):
                print("Could not load data: \(error)")
            case .success(let moreCommentsListData):
                self.extractComments(from: moreCommentsListData)
            }
            self.loadingMore = false
        }
    }
    
    private func extractComments(from list: MoreCommentsListData) {
        var moreComments = [CommentModel]()
        // Remove everything that is no comment data.
        var commentsData = list.commentsData.filter { $0.kind == .data }
        while !commentsData.isEmpty {
            if var commentModel = CommentModel(from: commentsData.removeFirst()) {
                // Find next index where comment is not a reply (depth == 0).
                if let index = commentsData.firstIndex(where: { $0.depth == 0 }) {
                    // If index is 0, then there are no replies to current comment.
                    if index != 0 { commentModel.add(replies: &commentsData[0..<index]) }
                } else {
                    // If index was not found, the rest of comments are replies to this.
                    commentModel.add(replies: &commentsData[0..<commentsData.endIndex])
                }
                moreComments.append(commentModel)
            }
        }
        DispatchQueue.main.async {
            self.comments.append(contentsOf: moreComments)
        }
    }
    
    private func extractComments(from list: [CommentDataList]) {
        guard list.count >= 2 else { return }
        DispatchQueue.main.async { [weak self] in
            self?.comments = list[1].commentsData.compactMap {
                CommentModel(from: $0)
            }
            if case let .more(more) = list[1].commentsData.last?.kind {
                self?.more = more
            }
        }
    }

    func postComment() {
       if newComment.isEmpty {
           return
        }
        guard let commentModel = CommentModel(body: newComment) else { return }
        comments.insert(commentModel, at: 0)
        newComment = ""
    }
}

func loadData<T: Decodable>(from url: URL, _ completion: @escaping (Result<T, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        if let data = data {
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
                return
            } catch (let decodingError) {
                completion(.failure(decodingError))
            }
        }
    }.resume()
}
