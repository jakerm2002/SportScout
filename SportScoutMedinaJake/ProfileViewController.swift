//
//  ProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var bioText: UILabel!
    @IBOutlet weak var sportsText: UILabel!
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docRef = db.collection("users").document(String(uid))
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.nameText.text = String(describing: document.get("fullName")!)
                self.usernameText.text = String(describing: document.get("username")!)
                self.weightText.text = String(describing: document.get("weight")!)
                var newHeight:String = String(describing: document.get("feet")!) + " ft " + String(describing: document.get("inches")!) + " in"
                self.heightText.text = newHeight
                self.locationText.text = String(describing: document.get("location")!)
                self.sportsText.text = String(describing: document.get("sports")!)
                self.bioText.text = String(describing: document.get("bio")!)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
