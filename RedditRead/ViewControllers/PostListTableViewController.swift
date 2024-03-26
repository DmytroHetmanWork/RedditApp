//
//  PostListTableViewController.swift
//  HT_2
//
//  Created by Пермяков Андрей on 21.02.2024.
//

import UIKit
import Combine

class PostListTableViewController: UITableViewController {
    private let portionNumber = 15
    private let subreddit = "apple"
    
    private var postsProvider = PostsProvider.shared
    
    private var posts: [Post] {
        postsProvider.savedOnly ? postsProvider.posts.filter(postsFilter) : postsProvider.posts
    }
    
    private var after: String? { posts.last?.name }
    
    private var loadingData = false
    
    private var postsFilter: (Post) -> Bool = { _ in true } {
        didSet {
            DispatchQueue.main.async { [weak self] in self?.tableView.reloadData() }
        }
    }
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    private var cancellable: Cancellable?
    
    
    
    private var isLoggedIn = false
    
    // MARK: - Outlets.
    
    @IBOutlet private weak var filterButton: UIBarButtonItem!
    
    // MARK: - Lifecycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        cancellable = postsProvider.$savedOnly
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedOnly in
                self?.updateSearchBar(savedOnly)
                self?.tableView.reloadData()
            }
        title = "r/\(subreddit)"
        loadPosts()
    }
    
    private func updateSearchBar(_ show: Bool) {
        let newHeight: CGFloat = show ? DrawingConstants.searchBarHeight : 0.0
        if show { self.tableView.tableHeaderView = self.searchBar }
        UIView.animate(withDuration: DrawingConstants.searchBarAnimationDuration) {
            self.searchBar.frame.size.height = newHeight
        } completion: { _ in
            if !show {
                self.tableView.tableHeaderView = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isLoggedIn {
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: false)
            isLoggedIn = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions.
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        postsProvider.savedOnly.toggle()
        filterButton.image = postsProvider.savedOnly ?
            Constants.filterButtonActive : Constants.filterButtonInactive
    }
    
    // MARK: - Table view data source.

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.postCellID,
            for: indexPath) as! PostTableViewCell
        cell.delegate = self
        cell.configure(with: posts[indexPath.row])
        return cell
    }
    
    private func loadPosts() {
        loadingData = true
        let countBeforeLoading = posts.count
        postsProvider.loadPosts(
            subreddit: subreddit,
            limit: portionNumber,
            after: self.after) { [weak self] in
                self?.loadingData = false
                if countBeforeLoading != self?.posts.count {
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
    }
    
    // MARK: - Navigation.

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.postSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.postSegueID,
              let destinationVC = segue.destination as? PostDetailsViewController,
              let index = tableView.indexPathForSelectedRow?.row
        else { return }
        destinationVC.post = posts[index]
        destinationVC.subreddit = subreddit
    }
    
    // MARK: - Pagination.
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !postsProvider.savedOnly, !loadingData, tableView.contentOffset.y +
            scrollView.frame.size.height >= scrollView.contentSize.height {
            loadPosts()
        }
    }
    
    // MARK: - Constants.
    
    private struct DrawingConstants {
        static let searchBarHeight: CGFloat = 50.0
        static let searchBarAnimationDuration = 0.2
    }
}

// MARK: - PostCellDelegate

extension PostListTableViewController: PostCellDelegate {
    func share(_ url: URL) {
        let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(avc, animated: true)
    }
    
    func save(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0 == post }) else { return }
        postsProvider.save(posts[index])
        if postsProvider.savedOnly {
            tableView.deleteRows(at: [IndexPath(index: index)], with: .automatic)
        } else {
            tableView.reloadRows(at: [IndexPath(index: index)], with: .none)
        }
    }
}

// MARK: - UISearchBarDelegate

extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if postsProvider.savedOnly {
            if searchText.isEmpty {
                postsFilter = { _ in true }
            } else {
                postsFilter = { $0.title.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
}
