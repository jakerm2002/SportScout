//
//  SSNewPostViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/27/23.
//

import UIKit
import AVFoundation
import AVKit

class SSNewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mediaView: UIView!
    
    let picker = UIImagePickerController()
    
    var avpController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
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
        case UTType.movie.identifier:
            let chosenVideo = info[.mediaURL] as! URL
            let player = AVPlayer(url: chosenVideo)
            player.allowsExternalPlayback = false
            avpController.player = player
            avpController.view.frame.size.height = mediaView.frame.height
            avpController.view.frame.size.width = mediaView.frame.width
            self.mediaView.addSubview(avpController.view)
            break
        default:
            break
        }
        
        dismiss(animated: true)
    }

    @IBAction func photoButtonPressed(_ sender: Any) {
        picker.allowsEditing = false
        addMediaButtonPressed(type: "photo")
    }
    
    @IBAction func videoButtonPressed(_ sender: Any) {
        // allow video trimming
        picker.allowsEditing = true
        addMediaButtonPressed(type: "video")
        
    }
}
