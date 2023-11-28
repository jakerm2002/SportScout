//
//  SSTimelineViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/22/23.
//

import UIKit

import FirebaseCore
//import FirebaseFirestore
import FirebaseFirestoreSwift
//import FirebaseStorage

class SSTimelineViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let timelineCollectionViewCellIdentifier = "TimelineCollectionViewCellIdentifier"
    
    let timelineToNewPostSegueIdentifier = "TimelineToNewPostSegueIdentifier"
    
    var searchBar = UISearchBar()
    
    var viewableTimelinePosts: [TimelinePost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        
        // dismiss search bar when user scrolls the collection view
        collectionView.keyboardDismissMode = .onDrag
        
//        searchBar.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(SSTimelineViewController.newPostButtonPressed))
        navigationItem.titleView = searchBar
        
        Task {
            await fetchTimelinePosts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewableTimelinePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineCollectionViewCellIdentifier, for: indexPath)
        
        return cell
    }
    
    @MainActor
    func fetchTimelinePosts() async {
        do {
            let timelinePostsResult = try await db.collection("timelinePosts").order(by: "createdAt").getDocuments().documents
            for post in timelinePostsResult {
                viewableTimelinePosts.append(try post.data(as: TimelinePost.self))
            }
            print(viewableTimelinePosts.debugDescription)
        } catch {
            print("There was an issue fetching timeline posts: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let numColumns = 1.0
        let cellSize = (containerWidth - 40) / numColumns
        
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.collectionViewLayout = layout
    }
    
    @objc func newPostButtonPressed() {
        performSegue(withIdentifier: timelineToNewPostSegueIdentifier, sender: nil)
    }

}
