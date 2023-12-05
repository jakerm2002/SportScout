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
import Nuke
import NukeUI
import NukeExtensions
import NukeVideo
import FirebaseStorageUI
import AVFoundation

class SSTimelineViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let timelineCollectionViewCellIdentifier = "TimelineCollectionViewCellIdentifier"
    
    let timelineToNewPostSegueIdentifier = "TimelineToNewPostSegueIdentifier"
    
    var searchBar = UISearchBar()
    
    private let refreshControl = UIRefreshControl()
    
    var viewableTimelinePosts: [TimelinePost] = []
    var filteredViewableTimelinePosts: [TimelinePost] = []
    var filtered: Bool = false
    
    var topOffset: CGFloat?
    
    let spinnerVC = SpinnerViewController()
    
    var mediaLoaderQueue: DispatchQueue!
    
    // MARK: Nuke Image Loading
//    var preheater = ImagePrefetcher(pipeline: ImagePipeline.shared)
//    var requests: [ImageRequest]?
//    // You need to populate remoteImages with the URLs you want prefetched
//    var remoteImages = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Filter posts by username"
        
        // dismiss search bar when user scrolls the collection view
        collectionView.keyboardDismissMode = .onDrag
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [.foregroundColor : UIColor.secondaryLabel])
        refreshControl.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
//        searchBar.delegate = self
        
        mediaLoaderQueue = DispatchQueue(label: "mediaLoaderQueue", qos: .userInteractive)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(SSTimelineViewController.newPostButtonPressed))
        navigationItem.titleView = searchBar
        
        topOffset = collectionView.contentOffset.y - 150
        
        // spinner wheel for first loading state
        addChild(spinnerVC)
        spinnerVC.view.frame = view.frame
        view.addSubview(spinnerVC.view)
        spinnerVC.didMove(toParent: self)
        
        // TODO: attempt Nuke cache videos
//        let pipeline = ImagePipeline {
//            $0.dataLoader = DataLoader(configuration: {
//                // Disable disk caching built into URLSession
//                let conf = DataLoader.defaultConfiguration
//                conf.urlCache = nil
//                return conf
//            }())
//
//            $0.imageCache = ImageCache()
//            $0.dataCache = try! DataCache(name: "com.github.kean.Nuke.DataCache")
//        }
        
        // for video playback
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)

        Task {
            await fetchTimelinePosts()
            spinnerVC.willMove(toParent: nil)
            spinnerVC.view.removeFromSuperview()
            spinnerVC.removeFromParent()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let search = searchBar.text {
            if text.count == 0 {
                filterText(String(search.dropLast()))
            } else {
                filterText(search+text)
            }
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filtered = false
            filteredViewableTimelinePosts.removeAll()
            collectionView.reloadData()
        }
    }
    
    func filterText(_ query: String) {
        filteredViewableTimelinePosts.removeAll()
        for timelinePost in viewableTimelinePosts {
            if ((timelinePost.authorAsUserModel?.username.lowercased().contains(query.lowercased()))!) {
                filteredViewableTimelinePosts.append(timelinePost)
            }
        }
        collectionView.reloadData()
        filtered = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewableTimelinePosts.count == 0 && !self.spinnerVC.view.isDescendant(of: self.view) {
            self.collectionView.setEmptyMessage("No Posts")
        } else {
            self.collectionView.restore()
        }
        if (!filteredViewableTimelinePosts.isEmpty) {
            return filteredViewableTimelinePosts.count
        }
        return viewableTimelinePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineCollectionViewCellIdentifier, for: indexPath) as! SSTimelineCollectionViewCell
        
        cell.imageView.image = nil
        cell.nukeLazyImageView.url = nil
        
        let row = indexPath.row
        let currentPost: TimelinePost
        if !filteredViewableTimelinePosts.isEmpty {
            currentPost = filteredViewableTimelinePosts[row]
        } else {
            currentPost = viewableTimelinePosts[row]
        }
        
        cell.authorRealNameLabel.text = currentPost.authorAsUserModel?.fullName
        cell.authorUsernameLabel.text = currentPost.authorAsUserModel?.username
        
        // TODO: display images
        if let url = currentPost.authorAsUserModel?.url {
            let imgRef = storage.reference().child(url)
            cell.authorProfileImage.sd_setImage(with: imgRef)
        }
        
        if currentPost.mediaType == "photo" {
            if let mediaPhoto = currentPost.mediaPath {
                let imgRef = storage.reference().child(mediaPhoto)
                cell.imageView.sd_setImage(with: imgRef, placeholderImage: nil)
//                cell.mediaView.isHidden = true
            }
        } else if currentPost.mediaType == "video" {
            if let mediaVideo = currentPost.mediaPath {
                cell.nukeLazyImageView.makeImageView = {
                    container in
                    if let type = container.type, type.isVideo, let asset = container.userInfo[.videoAssetKey] as? AVAsset {
                        let view = VideoPlayerView()
                        view.asset = asset
                        view.play()
                        return view
                    }
                    return nil
                }
                
                let videoRef = storage.reference(withPath: mediaVideo)
                
                videoRef.downloadURL() {
                    (url, error) in
                    if let error = error {
                        // Handle any errors
                        print("Error downloading video: \(error.localizedDescription)")
                    } else {
                        cell.nukeLazyImageView.url = url
//                        (cell.nukeLazyImageView.customImageView as! VideoPlayerView).playerLayer.player?.pause()
//                        cell.mediaView.isHidden = true
                    }
                }
            }
        } else {
//            cell.imageView.image = nil
//            cell.nukeLazyImageView.url = nil
            if let mediaType = currentPost.mediaType {
//                cell.mediaView.isHidden = false
            } else {
//                cell.mediaView.isHidden = true
            }
        }
        
        cell.mediaView.isHidden = true

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
        do {
            var newTimelinePosts: [TimelinePost] = []
            
            let timelinePostsResult = try await db.collection("timelinePosts").order(by: "createdAt", descending: true).getDocuments().documents
            for post in timelinePostsResult {
                var timelinePost = try post.data(as: TimelinePost.self)
                let author = try await timelinePost.author.getDocument(as: User.self)
                timelinePost.authorAsUserModel = author
                newTimelinePosts.append(timelinePost)
            }
            viewableTimelinePosts = newTimelinePosts
            print(viewableTimelinePosts.debugDescription)
            collectionView.reloadData()
        } catch {
            print("There was an issue fetching timeline posts: \(error.localizedDescription)")
        }
    }

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
        let cellSize = (containerWidth - 32) / numColumns
        
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = 20
//        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.collectionViewLayout = layout
        
        refreshControl.superview?.sendSubviewToBack(refreshControl)
    }
    
    @objc func newPostButtonPressed() {
        performSegue(withIdentifier: timelineToNewPostSegueIdentifier, sender: nil)
    }

}


extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .systemGray3
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 30.0, weight: .semibold)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restore() {
        self.backgroundView = nil
    }
}
