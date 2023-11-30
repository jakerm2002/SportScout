//
//  SSNewPostViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/27/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth
import AVFoundation
import AVKit

enum NewPostError: Error {
    case mediaUnavailable
    case mediaEmptyOrBadFormat
}

protocol SSSportModifier {
    func changeSport(newSport: String, newIndex: Int)
}

class SSNewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, SSSportModifier {
    
    var sports = [
        "Volleyball (indoor)",
        "Volleyball (sand)",
        "Spikeball",
        "Pickleball",
        "Soccer",
        "Frisbee",
        "Tennis",
        "Racquetball"
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var sportTableView: UITableView!
    
    weak var activeField: UITextView?
    
    var currentImageMedia: UIImage?
    var currentVideoMedia: URL?
    
    // true if the user has selected media to upload, regardless of upload status
    var userDidSubmitMedia = false
    var userDidChangeCaption = false
    var userMediaSubmissionType: String?
    
    // placeholder text for the descriptionTextView
    let placeholderText = "Caption"
    let placeholderTextColor = UIColor.systemGray
    
    let picker = UIImagePickerController()
    
    let SSSportChooserSegueIdentifier = "SSSportChooserSegueIdentifier"
    
    let newPostSportTableViewCellIdentifier = "NewPostSportTableViewCellIdentifier"
    
    var currentScrollViewOffset: CGPoint?
    
    // used if displaying an uploaded video
    var avpController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.keyboardDismissMode = .onDrag
        
        picker.delegate = self
        descriptionTextView.delegate = self
        
        sportTableView.delegate = self
        sportTableView.dataSource = self
        sportTableView.register(UINib(nibName: "SSNewPostSportTableViewCell", bundle: nil), forCellReuseIdentifier: newPostSportTableViewCellIdentifier)
        
        // styling for description text view
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.systemGray2.cgColor
        descriptionTextView.layer.cornerRadius = 5.0
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = placeholderTextColor
    }
    
    func changeSport(newSport: String, newIndex: Int) {
        let sportIndexPath = IndexPath(row: 0, section: 0)
        let sportCell = sportTableView.cellForRow(at: sportIndexPath) as! SSNewPostSportTableViewCell
        sportCell.selectedLabel.text = newSport
        sportCell.selectedSportIndex = newIndex
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newPostSportTableViewCellIdentifier, for: indexPath) as! SSNewPostSportTableViewCell

        cell.titleLabel.text = "Sport"
        cell.selectedLabel.text = "None"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = SSSportChooser()
        nextVC.items = sports
        nextVC.dismissOnRowSelect = true
        let sportIndexPath = IndexPath(row: 0, section: 0)
        let sportCell = sportTableView.cellForRow(at: sportIndexPath) as! SSNewPostSportTableViewCell
        nextVC.delegate = self
        nextVC.selectedRowIndex = sportCell.selectedSportIndex
        
        let navVC = UINavigationController(rootViewController: nextVC)
        present(navVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func addMediaButtonPressed(type: String) {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Use camera", style: .default) {
            (action) in
            self.cameraButtonSelected(type: type)
        })
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default) {
            (action) in
            self.libraryButtonSelected(type: type)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func libraryButtonSelected(type: String) {
        picker.sourceType = .photoLibrary
        if type == "photo" {
            picker.mediaTypes = [UTType.image.identifier as String]
        } else {
            picker.mediaTypes = [UTType.movie.identifier as String]
        }
        present(picker,animated:true)
    }
    
    func cameraButtonSelected(type: String) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    (granted) in
                    guard granted == true else { return }
                }
            case .authorized:
                break
            default:
                let accessDeniedAlert = UIAlertController(title: "No camera access", message: "Access to camera was denied, go to Settings->Privacy->Camera", preferredStyle: .alert)
                accessDeniedAlert.addAction(UIAlertAction(title: "OK", style: .default))
                present(accessDeniedAlert,animated:true)
                return
            }
            picker.sourceType = .camera
            if type == "photo" {
                picker.mediaTypes = [UTType.image.identifier as String]
                picker.cameraCaptureMode = .photo
            } else {
                picker.mediaTypes = [UTType.movie.identifier as String]
                picker.cameraCaptureMode = .video
            }
            present(picker,animated: true)
        } else {
            let noCameraAlert = UIAlertController(title: "No camera", message: "No rear camera detected", preferredStyle: .alert)
            noCameraAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(noCameraAlert,animated:true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let mediaType = info[.mediaType] as? String else {return}
        
        // put the photo/video into the mediaView
        switch mediaType {
        case UTType.image.identifier:
            let chosenImage = info[.originalImage] as! UIImage
            currentImageMedia = chosenImage
            let imageView = UIImageView(image: chosenImage)
            imageView.frame.size.height = mediaView.frame.height
            imageView.frame.size.width = mediaView.frame.height
            imageView.contentMode = .scaleAspectFit
            mediaView.addSubview(imageView)
            userDidSubmitMedia = true
            userMediaSubmissionType = "photo"
        case UTType.movie.identifier:
            let chosenVideo = info[.mediaURL] as! URL
            currentVideoMedia = chosenVideo
            let player = AVPlayer(url: chosenVideo)
            player.allowsExternalPlayback = false
            avpController.player = player
            avpController.view.frame.size.height = mediaView.frame.height
            avpController.view.frame.size.width = mediaView.frame.width
            self.mediaView.addSubview(avpController.view)
            userDidSubmitMedia = true
            userMediaSubmissionType = "video"
        default:
            print("no media selected")
            break
        }
        
        dismiss(animated: true)
    }
    
    // Dismiss keyboard when user clicks on the view outside of the descriptionTextView
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Dismiss keyboard when 'return' pressed
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
//        let scrollPoint : CGPoint = CGPoint.init(x:0, y:textView.frame.origin.y)
//        let f: CGFloat = self.view.frame.height / 2 - textView.frame.height
        let scrollPoint = CGPoint.init(x:0, y: textView.frame.origin.y - 250)
        
        currentScrollViewOffset = scrollView.contentOffset
        scrollView.setContentOffset(scrollPoint, animated: true)
        
        // for placeholder text
        if textView.textColor == placeholderTextColor {
            userDidChangeCaption = true
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if let previousScrollOffset = currentScrollViewOffset {
            scrollView.setContentOffset(previousScrollOffset, animated: true)
        }

        // for placeholder text
        if textView.text.isEmpty {
            userDidChangeCaption = false
            textView.text = placeholderText
            textView.textColor = placeholderTextColor
        }
    }
    
    // uploads media and returns the Firebase Storage path for the media
    @MainActor
    func attemptMediaUpload(postDocumentID: String) async -> String? {
        if userDidSubmitMedia {
            if userMediaSubmissionType == "photo" {
                do {
                    guard currentImageMedia != nil else {
                        throw NewPostError.mediaUnavailable
                    }
                    let imgRef = storage.reference().child("timelinePostMedia/\(postDocumentID)")
                    guard let imageData = currentImageMedia!.jpegData(compressionQuality: 0.8) else {
                        throw NewPostError.mediaEmptyOrBadFormat
                    }
                    
                    let resultMetadata = try await imgRef.putDataAsync(imageData, metadata: nil)
                    print("Media upload complete (photo).")
                    return resultMetadata.path
                } catch {
                    print("Error uploading media (photo): \(error.localizedDescription)")
                }
            } else if userMediaSubmissionType == "video" {
                do {
                    guard currentVideoMedia != nil else {
                        throw NewPostError.mediaUnavailable
                    }
                    let videoRef = storage.reference().child("timelinePostMedia/\(postDocumentID)")
                    let videoData = try Data(contentsOf: currentVideoMedia!)
                    
                    let uploadMetadata = StorageMetadata()
                    uploadMetadata.contentType = "video/quicktime"
                    
                    let resultMetadata = try await videoRef.putDataAsync(videoData, metadata: uploadMetadata)
                    print("Media upload complete (video).")
                    return resultMetadata.path
                } catch {
                    print("Error uploading media (video): \(error.localizedDescription)")
                }
            }
        }
        return nil
    }
    
    func createPost(ref: DocumentReference, uid: String, caption: String?, sport:String?, pathToFirebaseStorageMedia: String?) {
        let newPost = TimelinePost(
            author: db.collection("users").document(String(uid)),
            mediaType: userMediaSubmissionType,
            mediaPath: pathToFirebaseStorageMedia,
            caption: caption,
            sport: sport
        )
        
        do {
            try ref.setData(from: newPost) {
                _ in
                print("New timeline post created successfully in Firestore.")
                
                // TODO: add the event to the corresponding users' 'posts' array.
                // TODO: catch possible error from this operation
                //                    db.collection("users").document(uid).updateData([
                //                        "posts": FieldValue.arrayUnion([newPostReference])
                //                    ]) {
                //                        _ in
                //                        print("New post created successfully in Firestore.")
                //                        self.navigationController?.popViewController(animated: true)
                //                    }
            }
        }
        catch let error {
            print("Error creating timeline post in Firestore: \(error.localizedDescription)")
        }
    }
    
    func createUploadingAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Uploading Post...", message: nil, preferredStyle: .alert)
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()

        alert.view.addSubview(activityIndicator)
        alert.view.heightAnchor.constraint(equalToConstant: 95).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20).isActive = true
        
        return alert
    }

    @IBAction func photoButtonPressed(_ sender: Any) {
        // don't allow cropping for the picker if using a photo
        picker.allowsEditing = false
        addMediaButtonPressed(type: "photo")
    }
    
    @IBAction func videoButtonPressed(_ sender: Any) {
        // allow video trimming
        picker.allowsEditing = true
        addMediaButtonPressed(type: "video")
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        // the media must be uploaded to firebase. this can be done asynchronously from other tasks
        let sportCell = sportTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SSNewPostSportTableViewCell
        
        let postCaption = (!userDidChangeCaption || descriptionTextView.text.isEmpty) ? nil : descriptionTextView.text
        let postSport = sportCell.selectedLabel.text == "None" ? nil : sportCell.selectedLabel.text
        
        var validationErrors: [String] = []
        
        if !userDidSubmitMedia && (!userDidChangeCaption || postCaption == nil) {
            validationErrors.append("Post cannot be empty. You must upload media or write a caption.")
        }
        
        if !validationErrors.isEmpty {
            let alert = UIAlertController(title: "Can't share post", message: "", preferredStyle: .alert)
            for (idx, err) in validationErrors.enumerated() {
                if (idx != 0) {
                    alert.message?.append("\n")
                }
                alert.message?.append("\u{2022} \(err)")
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            print("New post validation error")
        } else {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let uploadingAlert = createUploadingAlert()
            present(uploadingAlert, animated: true)
            // let document ID be auto-generated
            let newPostReference = db.collection("timelinePosts").document()
            
            Task {
                let path = await attemptMediaUpload(postDocumentID: newPostReference.documentID)
                createPost(
                    ref: newPostReference,
                    uid: uid,
                    caption: postCaption,
                    sport: postSport,
                    pathToFirebaseStorageMedia: path
                )

                uploadingAlert.dismiss(animated: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
