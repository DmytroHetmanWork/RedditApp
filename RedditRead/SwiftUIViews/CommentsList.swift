//
//  CommentsList.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 17.04.2024.
//

import SwiftUI

struct CommentsList: View {
    @EnvironmentObject var viewModel: CommentsVM
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.comments) { commentBundle in
                        Comment(comment: commentBundle)
                            .onAppear {
                                viewModel.tryToLoadMore(currentItem: commentBundle)
                            }
                        terminatorV
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    private var terminatorV: some View {
        Color.gray
            .frame(height: 2)
            .padding(.vertical, 10)
    }
}
