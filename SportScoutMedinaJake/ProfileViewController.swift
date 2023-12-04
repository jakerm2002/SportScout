//
//  ProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var bioText: UILabel!
    @IBOutlet weak var sportsText: UILabel!
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    
    @IBOutlet weak var participantRequestTable: UITableView!
    
    var events: [Event]?
    var currentUser: User?
    var logoutSegueIdentifier = "LogoutSegue"
    var participantCellSegueIdentifier = "ParticipantCellSegue"
    var participantCellIdentifier = "ParticipantCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePhoto!.layer.cornerRadius = self.profilePhoto!.frame.size.height / 2
        self.profilePhoto.contentMode = .scaleAspectFill
        participantRequestTable.delegate = self
        participantRequestTable.dataSource = self
        self.fetchEventData()
        // Do any additional setup after loading the view.
    }
    
    func fetchEventData() {
        print("\nfetching event data")
        let user = Auth.auth().currentUser
        var uid: String = ""
        if let user = user {
            uid = user.uid
        }
        // get all events owned by this user
        db.collection("events").whereField("owner", isEqualTo: uid)
            .getDocuments() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                print("getting events")
                self.events = documents.compactMap { (queryDocumentSnapshot) -> Event? in
                    return try? queryDocumentSnapshot.data(as: Event.self)
                }
            }
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
                
                let imgRef = storage.reference().child(imageURL)
                self.profilePhoto.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "person.crop.circle"))
                
                self.fetchEventData()
                print(self.events == nil)
                
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
            let vc = segue.destination as? LoginViewController
        } else if segue.identifier == participantCellSegueIdentifier, let nextVC = segue.destination as? SSEventDetailsViewController, let row = participantRequestTable.indexPathForSelectedRow?.row
         {
            nextVC.event = events![row]
         }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of events user owns: \(String(describing: events?.count))")
        return events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: participantCellIdentifier, for: indexPath as IndexPath)
        
        cell.textLabel?.text = "Event: \( events![indexPath.row].name)"
        cell.detailTextLabel?.text = "Participants to review: \(String(describing: events![indexPath.row].requestedParticipants?.count))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: profileSegueIdentifier, sender: nil)
    }
}
