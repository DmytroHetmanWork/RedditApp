//
//  CommentDetails.swift
//  Reddit_comments
//
//  Created by Пермяков Андрей on 18.04.2024.
//

import SwiftUI
import UIKit

struct CommentDetails: View {
    @State private var isPresentingShare = false
    @Binding var isBeingPresented: Bool

    let comment: CommentModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                ScrollView(showsIndicators: false) {
                    creationDetails
                        .font(.callout)
                    Text(comment.body)
                        .font(.system(size: 24))
                    Text("Rating: \(comment.rating)")
                        .font(.callout)
                    Divider()
                    shareButton
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle(Text("Details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    isBeingPresented = false
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var creationDetails: some View {
        HStack {
            Text("/u/\(comment.username)")
            Spacer()
            Text("\(UtilityFuncs.convertToNice(comment.time))")
                .foregroundColor(.gray)
        }
    }
    
    private var shareButton: some View {
        Button {
            isPresentingShare = true
        } label: {
            HStack {
                Image(systemName: "arrow.up.square")
                Text("Share")
                    .bold()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(.black)
            .padding()
            .font(.system(size: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .sheet(isPresented: $isPresentingShare) {
            Share(activityItems: [comment.permalink])
        }
        .background(Color.white)
        .cornerRadius(25)
    }
}
