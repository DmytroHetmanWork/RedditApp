//
//  Constants+Utilities.swift
//  HT_2
//
//  Created by Пермяков Андрей on 21.02.2024.
//

import UIKit

struct Constants {
    static let postCellID = "postCell"
    static let postSegueID = "postSegue"
    
    static let bookmarkEmptyImage = UIImage(systemName: "bookmark")
    static let bookmarkFilledImage = UIImage(systemName: "bookmark.fill")
    
    static let ratingButtonPositive = UIImage(systemName: "arrow.up")
    static let ratingButtonNegative = UIImage(systemName: "arrow.down")
    
    static let filterButtonInactive = UIImage(systemName: "bookmark.circle")
    static let filterButtonActive = UIImage(systemName: "bookmark.circle.fill")
    
    static let placeholderImage = UIImage(named: "PlaceholderImage")
    // Big bookmark.
    static let bigBookmarkStrokeColor = UIColor.black.cgColor
    static let bigBookmarkFillColor = UIColor.white.cgColor
    static let bigBookmarkSide: CGFloat = 50.0
    // Big bookmark animation.
    static let bigBookmarkAnimationDuration: CGFloat = 0.4
    static let bigBookmarkSpringDamping: CGFloat = 0.6
    static let initialSpringVelocity: CGFloat = 0.4
    static let bigBookmarkScale: CGFloat = 1.3
}

struct UtilityFuncs {
    static func convertToNice(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            formatter.maximumUnitCount = 1

            return formatter.string(from: time) ?? String(time)
    }
    
    @inline(__always)
    static func details(from name: String, _ time: String, _ domain: String) -> String {
        "u/\(name) • \(time) • \(domain)"
    }
    // MARK: - Image "big bookmark" supplementary view.
    static func setImageSupplementaryView(for imageView: UIImageView) -> UIView {
        imageView.subviews.forEach { $0.removeFromSuperview() }
        let supplementaryView = UIView()
        let origin = CGPoint(
            x: imageView.bounds.midX - Constants.bigBookmarkSide / 2.0,
            y: imageView.bounds.midY - Constants.bigBookmarkSide / 2.0
        )
        supplementaryView.frame = CGRect(
            origin: origin,
            size: CGSize(width: Constants.bigBookmarkSide, height: Constants.bigBookmarkSide)
        )
        supplementaryView.backgroundColor = .clear
        supplementaryView.alpha = 0.0
        addBookmarkLayer(to: supplementaryView)
        imageView.addSubview(supplementaryView)
        return supplementaryView
    }
    
    static private func addBookmarkLayer(to view: UIView) {
        view.layer.sublayers?.removeAll()
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: view.frame.width, y: 0))
        path.addLine(to: CGPoint(x: view.frame.width, y: view.frame.height))
        path.addLine(to: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
        path.addLine(to: CGPoint(x: 0, y: view.frame.height))
        path.close()

        let bookmarkLayer = CAShapeLayer()
        bookmarkLayer.frame = view.bounds
        bookmarkLayer.path = path.cgPath
        bookmarkLayer.strokeColor = Constants.bigBookmarkStrokeColor
        bookmarkLayer.fillColor = Constants.bigBookmarkFillColor
        bookmarkLayer.lineWidth = 1.0
        view.layer.addSublayer(bookmarkLayer)
    }
}

extension IndexPath {
    init(index: Int) {
        self.init(item: index, section: 0)
    }
}
