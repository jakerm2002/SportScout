//
//  SSTimelineViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/22/23.
//

import UIKit

import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseStorage

class SSTimelineViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let timelineCollectionViewCellIdentifier = "TimelineCollectionViewCellIdentifier"
    
    let timelineToNewPostSegueIdentifier = "TimelineToNewPostSegueIdentifier"
    
    var searchBar = UISearchBar()
    
    private let refreshControl = UIRefreshControl()
    
    var viewableTimelinePosts: [TimelinePost] = []
    
    var topOffset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        
        // dismiss search bar when user scrolls the collection view
        collectionView.keyboardDismissMode = .onDrag
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
//        searchBar.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(SSTimelineViewController.newPostButtonPressed))
        navigationItem.titleView = searchBar
        
        topOffset = collectionView.contentOffset.y - 150
        
        // spinner wheel for first loading state
        let spinnerVC = SpinnerViewController()
        addChild(spinnerVC)
        spinnerVC.view.frame = view.frame
        view.addSubview(spinnerVC.view)
        spinnerVC.didMove(toParent: self)

        Task {
            await fetchTimelinePosts()
            spinnerVC.willMove(toParent: nil)
            spinnerVC.view.removeFromSuperview()
            spinnerVC.removeFromParent()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewableTimelinePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineCollectionViewCellIdentifier, for: indexPath) as! SSTimelineCollectionViewCell
        
        let row = indexPath.row
        let currentPost = viewableTimelinePosts[row]
        
        cell.authorUsernameLabel.text = currentPost.authorAsUserModel?.username
        
//        cell.authorProfileImage.image = currentPost.authorAsUserModel?.url
        
        let formatter = RelativeDateTimeFormatter()
        if let createdAt = currentPost.createdAt {
            cell.createdAtLabel.text = formatter.localizedString(for: createdAt, relativeTo: Date.now)
        } else {
            cell.createdAtLabel.text = "loading.."
        }
        
        cell.captionLabel.text = currentPost.caption
        cell.sportLabel.text = currentPost.sport
        
        return cell
    }
    
    @MainActor
    func fetchTimelinePosts() async {
        viewableTimelinePosts.removeAll()
        do {
            let timelinePostsResult = try await db.collection("timelinePosts").order(by: "createdAt", descending: true).getDocuments().documents
            for post in timelinePostsResult {
                var timelinePost = try post.data(as: TimelinePost.self)
                let author = try await timelinePost.author.getDocument(as: User.self)
                timelinePost.authorAsUserModel = author
                viewableTimelinePosts.append(timelinePost)
            }
            print(viewableTimelinePosts.debugDescription)
            collectionView.reloadData()
        } catch {
            print("There was an issue fetching timeline posts: \(error.localizedDescription)")
        }
    }
    
//    @MainActor
//    func fetchUserImage(imgPath: String) async {
//    
//        do {
//            let imageRef = try await storage.reference(forURL: imgPath).getData(maxSize: 1024*1024, completion: {_,_ in })
//            collectionView.reloadItems(at: <#T##[IndexPath]#>)
//        } catch {
//            print("There was an issue fetching timeline posts: \(error.localizedDescription)")
//        }
//    }
    

    @objc func doRefresh(refreshControl: UIRefreshControl) {
        print("refreshing")
        Task {
            await fetchTimelinePosts()
        }
        DispatchQueue.main.async {
            refreshControl.endRefreshing()
        }
    }
    
    override func viewDidLayoutSubviews() {
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let numColumns = 1.0
        let cellSize = (containerWidth - 40) / numColumns
        
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.collectionViewLayout = layout
        
        refreshControl.superview?.sendSubviewToBack(refreshControl)
    }
    
    @objc func newPostButtonPressed() {
        performSegue(withIdentifier: timelineToNewPostSegueIdentifier, sender: nil)
    }

}
