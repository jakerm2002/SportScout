//
//  SSOtherUserProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Ashley Nicole Yude on 11/23/23.
//

import UIKit
import Firebase
import FirebaseStorage

class SSOtherUserProfileViewController: UIViewController, UIScrollViewDelegate {
    
    var user: User?
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var bioText: UILabel!
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var sportsText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePhoto!.layer.cornerRadius =
        self.profilePhoto!.frame.size.height / 2
        self.profilePhoto.contentMode = .scaleAspectFill
        
        // get user passed in and show profile
        // TODO: USER PFP
        if let url = user!.url {
            let fileRef = storage.reference(withPath: url)
            fileRef.getData(maxSize: 1024 * 1024) { data, err in
                if err == nil && data != nil {
                    self.profilePhoto.image = UIImage(data: data!)
                }
            }
        }
        nameText.text = user!.fullName
        usernameText.text = user!.username
        bioText.text = user!.bio
        sportsText.text = user!.sports
        weightText.text = "\(user!.weight) lbs"
        heightText.text = "\(user!.feet) '\(user!.inches)"
        locationText.text = user!.location

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        var imageURL = ""
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let docRef = db.collection("users").document(String(uid))
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                self.nameText.text = String(describing: document.get("fullName")!)
//                self.usernameText.text = String(describing: document.get("username")!)
//                self.weightText.text = String(describing: document.get("weight")!) + "lbs"
//                let newHeight:String = String(describing: document.get("feet")!) + " ft " + String(describing: document.get("inches")!) + " in"
//                self.heightText.text = newHeight
//                self.locationText.text = String(describing: document.get("location")!)
//                self.sportsText.text = String(describing: document.get("sports")!)
//                self.bioText.text = String(describing: document.get("bio")!)
//                imageURL = String(describing: document.get("url")!)
//            } else {
//                print("Document does not exist")
//            }
//        }
//        let fileRef = Storage.storage().reference().child(imageURL)
//        fileRef.getData(maxSize: 1024 * 1024) { data, err in
//            if err == nil && data != nil {
//                print("retrieve worked")
//                self.profilePhoto.image = UIImage(data: data!)
//            }
//        }
    }
}
