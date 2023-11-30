//
//  ProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var bioText: UILabel!
    @IBOutlet weak var sportsText: UILabel!
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    
    var logoutSegueIdentifier = "LogoutSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePhoto!.layer.cornerRadius =
        self.profilePhoto!.frame.size.height / 2
        self.profilePhoto.contentMode = .scaleAspectFill
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docRef = db.collection("users").document(String(uid))
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.nameText.text = String(describing: document.get("fullName")!)
                self.usernameText.text = String(describing: document.get("username")!)
                self.weightText.text = String(describing: document.get("weight")!) + "lbs"
                let newHeight:String = String(describing: document.get("feet")!) + " ft " + String(describing: document.get("inches")!) + " in"
                self.heightText.text = newHeight
                self.locationText.text = String(describing: document.get("location")!)
                self.sportsText.text = String(describing: document.get("sports")!)
                self.bioText.text = String(describing: document.get("bio")!)
                let imageURL = String(describing: document.get("url")!)
                
                let fileRef = storage.reference(withPath: imageURL)
                fileRef.getData(maxSize: 1024 * 1024) { data, err in
                    if err == nil && data != nil {
                        self.profilePhoto.image = UIImage(data: data!)
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            performSegue(withIdentifier: logoutSegueIdentifier, sender: self)
        } catch let signOutError {
            print(signOutError.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == logoutSegueIdentifier {
            guard let vc = segue.destination as? LoginViewController else { return }
        }
    }

}
