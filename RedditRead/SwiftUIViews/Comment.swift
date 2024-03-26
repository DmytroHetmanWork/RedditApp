//
//  Comment.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 18.04.2024.
//

import SwiftUI

struct Comment: View {
    let comment: CommentModel
    @State private var isPresentingDetail = false
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            HStack {
                terminatorH
                VStack(alignment: .leading) {
                    tappableDescription
                    ForEach(comment.replies) { reply in
                        Comment(comment: reply)
                    }
                }
            }
        }
    }
    
    private var terminatorH: some View {
        Color.gray
            .frame(width: 1)
            .padding(.horizontal, 10)
    }
    
    private var tappableDescription: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("/u/\(comment.username) • \(UtilityFuncs.convertToNice(comment.time))")
                .font(.caption)
            Text(comment.body)
                .font(.body)
            Text("Rating: \(comment.rating)")
                .font(.footnote)
        }
        .onTapGesture {
            isPresentingDetail.toggle()
        }
        .sheet(isPresented: $isPresentingDetail) {
            CommentDetails(isBeingPresented: $isPresentingDetail, comment: comment)
        }
    }
}
