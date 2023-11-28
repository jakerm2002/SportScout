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
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var sportTableView: UITableView!
    
    // true if the user has selected media to upload, regardless of upload status
    var userDidSubmitMedia = false
    
    // placeholder text for the descriptionTextView
    let placeholderText = "Caption"
    let placeholderTextColor = UIColor.systemGray
    
    let picker = UIImagePickerController()
    
    let SSSportChooserSegueIdentifier = "SSSportChooserSegueIdentifier"
    
    let newPostSportTableViewCellIdentifier = "NewPostSportTableViewCellIdentifier"
    
    // used if displaying an uploaded video
    var avpController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        present(nextVC, animated: true)
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
            let imageView = UIImageView(image: chosenImage)
            imageView.frame.size.height = mediaView.frame.height
            imageView.frame.size.width = mediaView.frame.height
            imageView.contentMode = .scaleAspectFit
            mediaView.addSubview(imageView)
            userDidSubmitMedia = true
        case UTType.movie.identifier:
            let chosenVideo = info[.mediaURL] as! URL
            let player = AVPlayer(url: chosenVideo)
            player.allowsExternalPlayback = false
            avpController.player = player
            avpController.view.frame.size.height = mediaView.frame.height
            avpController.view.frame.size.width = mediaView.frame.width
            self.mediaView.addSubview(avpController.view)
            userDidSubmitMedia = true
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
    
    // for placeholder text
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderTextColor {
            textView.text = ""
            textView.textColor = UIColor.label
        }
    }

    // for placeholder text
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = placeholderTextColor
        }
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
        
        let postCaption = descriptionTextView.text.isEmpty ? nil : descriptionTextView.text
        let postSport = sportCell.selectedLabel.text == "None" ? nil : sportCell.selectedLabel.text
        
        var validationErrors: [String] = []
        
        if !userDidSubmitMedia && postCaption == nil {
            validationErrors.append("Post cannot be empty. You must upload media or write a caption.")
        }
        
        if !validationErrors.isEmpty {
            let alert = UIAlertController(title: "Can't share post", message: "The following information is malformed:", preferredStyle: .alert)
            for err in validationErrors {
                alert.message?.append("\n\u{2022} \(err)")
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let newPost = TimelinePost(
                author: db.collection("users").document(String(uid)),
                mediaPath: nil,
                caption: postCaption,
                sport: postSport
            )
            
            // let document ID be auto-generated
            do {
                let newPostReference = db.collection("timelinePosts").document()
                try newPostReference.setData(from: newPost) {
                    _ in
                    print("New timeline post created successfully in Firestore.")
                    self.navigationController?.popViewController(animated: true)
                    
                    
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
            } catch let error {
                print("Error creating timeline post in Firestore: \(error.localizedDescription)")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
