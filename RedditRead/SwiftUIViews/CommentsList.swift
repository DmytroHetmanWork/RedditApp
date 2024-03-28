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
        Divider()
        addComment
    }

    private var terminatorV: some View {
        Color.gray
            .frame(height: 2)
            .padding(.vertical, 10)
    }

    private var addComment: some View {
        HStack {
            TextField("Add your comment", text: $viewModel.newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(nil)
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                .shadow(color: Color.black.opacity(0.1), radius: 2)

            Button(action: {
                viewModel.postComment()
            }) {
                Image(systemName: "plus")
                    .frame(width: 22, height: 22)
                    .foregroundColor(.black)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 2)
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 16))
        .background(Color.white)
        .cornerRadius(10)
    }
}
