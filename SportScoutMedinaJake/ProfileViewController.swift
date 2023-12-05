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
    
    var eventsOwnedByThisUser: [Event]?
    var eventsOwnedWithActiveRequests: [Event]?
    var invites: [Event]?
    var currentUser: User?
    var logoutSegueIdentifier = "LogoutSegue"
    var participantCellSegueIdentifier = "ParticipantCellSegue"
    var participantCellIdentifier = "ParticipantCell"
    let requestsSection = 1
    let invitesSection = 0
    
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
        
        let userRef = db.collection("users").document(uid)
        
        // get all events owned by this user
        db.collection("events").whereField("owner", isEqualTo: userRef)
            .getDocuments() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                print("getting events")
                self.eventsOwnedByThisUser = documents.compactMap { (queryDocumentSnapshot) -> Event? in
                    return try? queryDocumentSnapshot.data(as: Event.self)
                }
                self.eventsOwnedWithActiveRequests = documents.compactMap { (queryDocumentSnapshot) -> Event? in
                    let element = try? queryDocumentSnapshot.data(as: Event.self)
                    if element?.requestedParticipants != nil && (element?.requestedParticipants!.count)! > 0 {
                        return element
                    }
                    return nil
                }
                self.participantRequestTable.reloadData()
            }
        
        // get all invites sent to this user
        db.collection("events").whereField("invitedParticipants", arrayContains: userRef)
            .getDocuments() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                print("getting invites")
                self.invites = documents.compactMap { (queryDocumentSnapshot) -> Event? in
                    return try? queryDocumentSnapshot.data(as: Event.self)
                }
                self.participantRequestTable.reloadData()
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
                print(self.eventsOwnedByThisUser == nil)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == logoutSegueIdentifier {
            let vc = segue.destination as? LoginViewController
        } else if segue.identifier == participantCellSegueIdentifier, let nextVC = segue.destination as? SSEventDetailsViewController, let row = participantRequestTable.indexPathForSelectedRow?.row, let section = participantRequestTable.indexPathForSelectedRow?.section, let selectedIndexPath = participantRequestTable.indexPathForSelectedRow
         {
            if section == invitesSection {
                nextVC.event = invites![row]
                nextVC.documentID = invites![row].id!
            } else if section == requestsSection {
                nextVC.event = eventsOwnedByThisUser![row]
                nextVC.documentID = eventsOwnedByThisUser![row].id!
            }
            participantRequestTable.deselectRow(at: selectedIndexPath, animated: true)
         }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: participantCellIdentifier, for: indexPath as IndexPath)
        
        switch indexPath.section {
        case invitesSection:
            cell.textLabel?.text = "Event: \( invites![indexPath.row].name)"
            cell.detailTextLabel?.text = "Accept or Reject this event invitaton"
        
        case requestsSection:
            cell.textLabel?.text = "Event: \( eventsOwnedWithActiveRequests![indexPath.row].name)"

            var rparticipants = eventsOwnedWithActiveRequests![indexPath.row].requestedParticipants
            
            if (rparticipants != nil) {
                for rp in rparticipants! {
                    print("participant who requested: \(rp)")
                }
            }
            
            cell.detailTextLabel?.text = "Participants to review: \( eventsOwnedWithActiveRequests![indexPath.row].requestedParticipants!.count )"
        default:
            break
        }
        
        return cell
    }
    
    let types = ["Events you're invited to", "Requests to join your events"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return types[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case requestsSection:
            if eventsOwnedWithActiveRequests == nil || eventsOwnedWithActiveRequests?.count == 0 {
                return 0
            }
            return eventsOwnedWithActiveRequests!.count
        case invitesSection:
            print("\nnumber of events user is invited to: \(String(describing: invites?.count))")
            return invites?.count ?? 0
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
