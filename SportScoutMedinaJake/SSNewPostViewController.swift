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
    
    @IBAction func addMediaButtonPressed(_ sender: Any) {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Use camera", style: .default) {
            (action) in
            self.cameraButtonSelected()
        })
        alert.addAction(UIAlertAction(title: "Choose from library", style: .default) {
            (action) in
            self.libraryButtonSelected()
        })
        present(alert, animated: true)
    }
    
    func libraryButtonSelected() {
        // allow photo cropping and video trimming
        picker.allowsEditing = true
        
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [UTType.image.identifier as String, UTType.movie.identifier as String]
        present(picker,animated:true)
    }
    
    func cameraButtonSelected() {
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
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.mediaTypes = [UTType.image.identifier as String, UTType.movie.identifier as String]
            picker.cameraCaptureMode = .photo
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

}
