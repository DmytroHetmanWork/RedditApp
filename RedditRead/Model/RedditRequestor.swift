//
//  RedditRequestor.swift
//  HT_2
//
//  Created by Пермяков Андрей on 13.02.2024.
//

import Foundation

class RedditRequestor {
    func makeRequest(subreddit: String = "ios",
                     limit: Int = 1,
                     after: String? = nil,
                     _ completion: @escaping (Result<[PostData], Error>) -> Void) {
        var params = "limit=\(limit)"
        if let after = after { params.append("&after=\(after)") }
        guard let url = URL(string: "https://www.reddit.com/r/\(subreddit)/top.json?\(params)")
        else { return }
        performRequest(with: url, completion)
    }
    
    private func performRequest(with url: URL, _ completion: @escaping (Result<[PostData], Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error { completion(.failure(error)) }
                return
            }
            var decodedData: PostDataList? = nil
            do {
                decodedData = try JSONDecoder().decode(PostDataList.self, from: data)
                if let finalData = decodedData { completion(.success(finalData.posts)) }
            } catch let exception {
                completion(.failure(exception))
            }
        }.resume()
    }
}
