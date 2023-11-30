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
    
    let spinnerVC = SpinnerViewController()
    
    var mediaLoaderQueue: DispatchQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        
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

        Task {
            await fetchTimelinePosts()
            getMediaForEachPost()
            spinnerVC.willMove(toParent: nil)
            spinnerVC.view.removeFromSuperview()
            spinnerVC.removeFromParent()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewableTimelinePosts.count == 0 && !self.spinnerVC.view.isDescendant(of: self.view) {
            self.collectionView.setEmptyMessage("No Posts")
        } else {
            self.collectionView.restore()
        }
        return viewableTimelinePosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineCollectionViewCellIdentifier, for: indexPath) as! SSTimelineCollectionViewCell
        
        let row = indexPath.row
        let currentPost = viewableTimelinePosts[row]
        
        cell.authorUsernameLabel.text = currentPost.authorAsUserModel?.username
        
        // if the user's image is available, display it
        if let authorImageData = currentPost.authorImageData {
            cell.mediaView.isHidden = true
            cell.imageView.image = UIImage(data: authorImageData)
        } else {
            cell.imageView.image = nil
        }
//        if let profilePic = currentPost.authorImageData {
//            cell.authorProfileImage.image = UIImage(data: profilePic)
//        } else {
//            Task {
//                if let path = currentPost.authorAsUserModel?.url {
//                    print("going to fetch image for \(indexPath.row)")
//                    await fetchImage(imgPath: path, indexPath: indexPath, viewToChange: "profile")
//                }
//            }
//        }
        
//        // begin fetching media
//        if currentPost.mediaType == "photo" {
//            if let mediaImageData = currentPost.mediaImageData {
////                cell.mediaView.addImage(imageData: mediaImageData)
////                cell.stackView.distribution = .fillProportionally
//                
//                
//                
////                let imageSubview = UIImageView()
////                imageSubview.image = UIImage(data: mediaImageData)
////                imageSubview.contentMode = .scaleAspectFit
////                cell.stackView.subviews[1].removeFromSuperview()
////                cell.stackView.insertArrangedSubview(imageSubview, at: 1)
////                cell.stackView.layoutIfNeeded()
////                cell.stackView.layoutIfNeeded()
//                
////                cell.mediaView.isHidden = true
////                cell.imageView.image = UIImage(data: mediaImageData)
////                cell.imageView.contentMode = .scaleAspectFit
////                cell.imageView.image = .checkmark
////                cell.mediaView.isHidden = true
//                cell.imageView.image = UIImage(data: mediaImageData)
//            } else {
////                Task {
////                    if let path = currentPost.mediaPath {
////                        await fetchImage(imgPath: path, indexPath: indexPath, viewToChange: "media")
////                    }
////                    print("successfully fetched timeline post image: \(currentPost.mediaPath)")
////                }
//            }
//        }
        
        if let mediaImageData = currentPost.mediaImageData {
            cell.mediaView.isHidden = true
            cell.imageView.image = UIImage(data: mediaImageData)
        } else {
            cell.imageView.image = nil
        }
        
//        getImage(url: photoUrl) { photo in
//            if photo != nil {
//                if cell.tag == tag {
//                    DispatchQueue.main.async {
//                        cell.locationImageView?.layer.cornerRadius = 5.0
//                        cell.locationImageView?.layer.masksToBounds = true
//                        cell.locationImageView?.image = photo
//                    }
//                }
//            }
//        }
        
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
    
    // retrieve an image from Firestore and execute a function once finished
    func getImageData(imgPath: String, completion: @escaping (Data?) -> ()) {
        storage.reference(withPath: imgPath).getData(maxSize: 3000 * 3000) { (data, error) -> Void in
            if data != nil {
                print("adding image for path \(imgPath)")
                completion(data!)
            } else {
                print("error fetching image with path \(imgPath): \(String(describing: error?.localizedDescription))")
                completion(nil)
            }
        }
    }
    
    // currently images only
    func getMediaForEachPost() {
        print("getMediaForEachPost")
        for (idx, post) in viewableTimelinePosts.enumerated() {
            print("looking at timeline posts with index \(idx)")
            // get the profile picture
            mediaLoaderQueue.async {
                if let imgPath = post.authorAsUserModel?.url {
                    self.getImageData(imgPath: imgPath) {
                        data in
                        if data != nil {
//                            DispatchQueue.main.async {
                                self.viewableTimelinePosts[idx].authorImageData = data
//                            }
                        }
                    }
                }
            }
            
            // get the post media
            if let imgPath = post.mediaPath {
                self.getImageData(imgPath: imgPath) {
                    data in
                    if data != nil {
//                        DispatchQueue.main.async {
                            self.viewableTimelinePosts[idx].mediaImageData = data
//                        }
                    }
                }
            }
            
            print("finished fetching media for \(idx)")
            // now that we have the media, refresh the cell
//            collectionView.reloadItems(at: [IndexPath(row: idx, section: 0)])
            collectionView.reloadData()
        }
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
    
    // retrieve an image from Firestore and execute a function once finished
    func getImage(url: String, completion: @escaping (UIImage?) -> ()) {
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if data != nil {
                print("adding image for url \(url)")
                let pic = UIImage(data: data!)
                completion(pic)
            } else {
                print("error fetching image for location with url \(url): \(String(describing: error?.localizedDescription))")
                completion(nil)
            }
        }
    }
    
    @MainActor
    func fetchImage(imgPath: String, indexPath: IndexPath, viewToChange: String) async {
        let imageRef = storage.reference(withPath: imgPath).getData(maxSize: 3000*3000) {
            (data, error) in
            if let error = error {
                print("There was an issue fetching \(viewToChange) image: \(error.localizedDescription)")
            } else {
                switch viewToChange {
                case "profile":
                    self.viewableTimelinePosts[indexPath.row].authorImageData = data
                case "media":
                    self.viewableTimelinePosts[indexPath.row].mediaImageData = data
                default:
                    print("fetchImage can't handle view of type \(viewToChange)")
                    break
                }
                print("fetching image for \(indexPath.row)")
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func downloadMedia(mediaPath: String) async {
        let mediaRef = storage.reference(withPath: mediaPath)
        // be careful with the max size
        mediaRef.getData(maxSize: INT64_MAX) {
            (data, error) in
            if let error = error {
                print("There was an issue downloading media for a cell's media view: \(error.localizedDescription)")
            } else {
                mediaRef.getMetadata() {
                    (metadata, metadataError) in
                    if let error = metadataError {
                        print("There was an issue downloading media for a cell's media view: \(error.localizedDescription)")
                    } else {
                        switch metadata?.contentType {
                        case "image/jpeg":
                            
                            break
//                        case
                        default:
                            print("There was an issue recognizing the media format for a cell's media view.")
                            break
                        }
                    }
                }
            }
        }
    }

    @objc func doRefresh(refreshControl: UIRefreshControl) {
        print("refreshing")
        Task {
            await fetchTimelinePosts()
            getMediaForEachPost()
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
        
        layout.itemSize = CGSize(width: cellSize, height: cellSize + 300)
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
