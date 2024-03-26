//
//  PostViewController.swift
//  HT_2
//
//  Created by Пермяков Андрей on 12.02.2024.
//

import UIKit
import SDWebImage
import SwiftUI

class PostDetailsViewController: UIViewController {
    // MARK: - Data.
    var postsProvider = PostsProvider.shared
    var post: Post?
    var subreddit: String?
    
    private var supplementaryView: UIView?
    
    // MARK: - Outlets.
    @IBOutlet private weak var postView: PostView!
    private weak var detailsLabel: UILabel! { postView.detailsLabel }
    private weak var descriptionLabel: UILabel! { postView.titleLabel }
    
    private weak var bookmarkButton: UIButton! { postView.bookmarkButton }
    private weak var shareButton: UIButton! { postView.shareButton }
    
    private weak var commentsButton: UIButton! { postView.commentsButton }
    private weak var ratingButton: UIButton! { postView.ratingButton }
    private weak var imageView: UIImageView! { postView.postImageView }
    
    private weak var imageHeightConstraint: NSLayoutConstraint! { postView.postImageHeightConstraint }
    
    @IBOutlet private weak var commentsContainerView: UIView!
    
    // MARK: - Actions.
    
    private func shareTapped(_ sender: UIButton) {
        guard let url = post?.url else { return }
        let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(avc, animated: true)
    }
    
    private func saveButtonTapped(_ sender: UIButton) {
        if let post = post { postsProvider.save(post) }
        self.post?.saved.toggle()
        display(post)
    }
    
    // MARK: - Lifecycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postView.shareButtonAction = shareTapped
        postView.bookmarkButtonAction = saveButtonTapped
        loadCommentsView()
        display(post)
    }
    
    // MARK: - Displaying post.
    
    private func display(_ post: Post?) {
        guard let post = post else { return }
        DispatchQueue.main.async {
            self.setImage(using: post.imageUrl)
            
            self.detailsLabel.text = UtilityFuncs
                .details(from: post.author, UtilityFuncs.convertToNice(post.time), post.domain)
            self.detailsLabel.sizeToFit()
            
            self.bookmarkButton.setImage(post.saved ? Constants.bookmarkFilledImage :
                                            Constants.bookmarkEmptyImage, for: .normal)
            
            self.descriptionLabel.text = post.title
            self.descriptionLabel.sizeToFit()
            
            self.ratingButton.setImage(post.isUpvoted ? Constants.ratingButtonPositive :
                                        Constants.ratingButtonNegative, for: .normal)
            self.ratingButton.setTitle(String(post.rating), for: .normal)
            self.ratingButton.setTitleColor(post.isUpvoted ? .systemGreen : .systemRed, for: .normal)
            self.ratingButton.tintColor = post.isUpvoted ? .systemGreen : .systemRed
            
            self.commentsButton.setTitle(String(post.comments), for: .normal)
        }
    }
    
    private func setImage(using url: URL?) {
        self.imageView.sd_setImage(with: url,
                                   placeholderImage: Constants.placeholderImage,
                                   options: SDWebImageOptions(rawValue: 0),
                                   completed: { (image, error, cache, urls) in
            if let image = image {
                self.imageView.image = image
            }
            self.layoutImage()
        })
    }
    
    private func layoutImage() {
        guard let image = imageView.image else { return }
        let ratio = image.size.width / image.size.height
        let newHeight = imageView.frame.width / ratio
        imageHeightConstraint.constant = newHeight
        imageView.isUserInteractionEnabled = true
        if supplementaryView == nil {
            supplementaryView = UtilityFuncs.setImageSupplementaryView(for: imageView)
        }
        setImageSaveListener()
        view.layoutIfNeeded()
    }
    
    private func setImageSaveListener() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tryToSaveWithAnimation))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
    }
    // Only save (not delete) when double tapped.
    @objc private func tryToSaveWithAnimation() {
        guard let post = post else { return }
        if !post.saved { saveWithAnimation(post) }
    }
    
    private func saveWithAnimation(_ post: Post) {
        if supplementaryView == nil {
            supplementaryView = UtilityFuncs.setImageSupplementaryView(for: imageView)
        }
        supplementaryView?.alpha = 1.0
        UIView.animate(
            withDuration: Constants.bigBookmarkAnimationDuration,
            delay: 0,
            usingSpringWithDamping: Constants.bigBookmarkSpringDamping,
            initialSpringVelocity: Constants.initialSpringVelocity
        ) {
            self.supplementaryView?.transform = CGAffineTransform(
                scaleX: Constants.bigBookmarkScale,
                y: Constants.bigBookmarkScale
            )
        } completion: { _ in
            self.supplementaryView?.alpha = 0.0
            self.supplementaryView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.postsProvider.save(post)
            self.post?.saved.toggle()
            self.display(self.post)
        }
    }
    
    
    
    // MARK: - Comments.
    
    private func loadCommentsView() {
        guard let postId = post?.id, let subreddit = subreddit else { return }
        let hostingVC = UIHostingController(
            rootView: CommentsList()
                .environmentObject(CommentsVM(subreddit: subreddit, id: postId))
        )
        self.addChild(hostingVC)
        self.commentsContainerView.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
        
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.topAnchor.constraint(equalTo: commentsContainerView.topAnchor).isActive = true
        hostingVC.view.trailingAnchor.constraint(equalTo: commentsContainerView.trailingAnchor).isActive = true
        hostingVC.view.leadingAnchor.constraint(equalTo: commentsContainerView.leadingAnchor).isActive = true
        hostingVC.view.bottomAnchor.constraint(equalTo: commentsContainerView.bottomAnchor).isActive = true
    }
}
