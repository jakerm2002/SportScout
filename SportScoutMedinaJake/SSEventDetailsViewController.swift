//
//  SSEventDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/1/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SSEventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource /*, ParticipantsChanger*/ {
    
    
    var participantCellIdentifier = "SSEventDetailsParticipantCellIdentifier"
    var profileSegueIdentifier = "SegueToSelectedUserProfile"
    
    var event: Event! // set from location VC
    var confirmedParticipants: [User] = []
    let confirmedSection = 0
    var invitedParticipants: [User] = []
    let invitedSection = 1
    var requestedParticipants: [User] = []
    let requestedSection = 2
    var documentID = "" // set from location VC
    var userIsEventOwner = false
    
    @IBOutlet var eventOwnerLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var eventDescription: UITextView!
    @IBOutlet var numParticipantsLabel: UILabel!
    @IBOutlet var participantList: UITableView!
    @IBOutlet weak var requestToJoinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantList.delegate = self
        participantList.dataSource = self
        
        // initialize swipe gestures to remove/accept participants
        let left = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
                left.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
        right.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(right)
        
        checkIfUserIsOwner()
        
        // populate data depending on user status
        if userIsEventOwner {
            // hide request to join button
            requestToJoinButton.isHidden = true
            // make participant table show confirmed, pending invite/invited, requested to join
        }
            // make participant table show only confirmed participants if not
        
        print("Fetching data")
        eventDescription.isEditable = false
        // Do any additional setup after loading the view.
        fetchParticipantData()
        fetchEventData()
    }
    
    // TODO: Write functionality
    @IBAction func requestToJoinPressed(_ sender: Any) {
    }
    
    // PARTICIPANT TABLE CODE
    
    class Participant {
        var user: [User]?
        var participantType: String?
        
        init(user: User? = nil, participantType: String? = nil) {
            self.user?.append(user!)
            self.participantType = participantType
        }
    }
    
    let participantTypes = ["Confirmed", "Pending Invite", "Requested"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if userIsEventOwner {
            return participantTypes.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return participantTypes[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case confirmedSection:
            return confirmedParticipants.count
        case invitedSection:
            return invitedParticipants.count
        case requestedSection:
            return requestedParticipants.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: participantCellIdentifier, for: indexPath) as! SSEventDetailsParticipantTableViewCell
        
//        let participant = event.participants![indexPath.row]
        
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        
        if userIsEventOwner {
            
            var cellUsername = ""
            var cellImage:UIImage?
            
            // TODO: give pfp to participants in list
            //        cell.imageView?.image = currentParticipants[indexPath.row].user?.
            switch indexPath.section {
            case confirmedSection:
                cellUsername = confirmedParticipants[indexPath.row].username
                //            cellImage = confirmedParticipants[indexPath.row].image
                
            case invitedSection:
                cellUsername = invitedParticipants[indexPath.row].username
                //            cellImage = invitedParticipants[indexPath.row].image
                
            case requestedSection:
                cellUsername = requestedParticipants[indexPath.row].username
                //            cellImage = requestedParticipants[indexPath.row].image
                
            default:
                break
            }
            
            cell.username.text = cellUsername
            cell.imageView?.image = cellImage
        } else {
            // show only confirmed participants
            if indexPath.section == confirmedSection {
                cell.username.text = confirmedParticipants[indexPath.row].username
//                cell.imageView?.image = confirmedParticipants.image
            }
        }
        return cell
    }
    
    // TODO: Clicking on a user in participant table will lead to their profile page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: profileSegueIdentifier, sender: nil)
    }
    
    // delete from core data
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let pizzaToDelete = corePizzas[indexPath.row]
//            context.delete(pizzaToDelete)
//            pizzas.remove(at: indexPath.row)
//            corePizzas.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            saveContext()
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }
    
    // swipe gestures to accept/remove participants for event owner
    @IBAction func recognizeSwipeGesture(recognizer: UISwipeGestureRecognizer)
    {
        if recognizer.state == .ended {
            // accept participant
            if recognizer.direction == .right {
                
            }
            
        }
    }
    
    
    // TODO: populate Profile of user pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegueIdentifier,
           let nextVC = segue.destination as? SSOtherUserProfileViewController,
           let participantSection = participantList.indexPathForSelectedRow?.section,
           let participantRow = participantList.indexPathForSelectedRow?.row
        {
            print("seguing to user profile in section: \(participantSection) at row: \(participantRow)")
            var chosenParticipantProfile:User?
            
            switch participantSection {
            case confirmedSection:
                chosenParticipantProfile = confirmedParticipants[participantRow]
                print("chosen profile: \(chosenParticipantProfile?.username ?? "none")")
                
            case invitedSection:
                chosenParticipantProfile = invitedParticipants[participantRow]
                
            case requestedSection:
                chosenParticipantProfile = requestedParticipants[participantRow]
                
            default:
                break
            }
            
            // populate profile
            print("final chosen participant: \(chosenParticipantProfile?.username ?? "none")")
            nextVC.user = chosenParticipantProfile
            
//            nextVC.bioText.text = chosenParticipantProfile.bio
//            nextVC.heightText.text = "\(chosenParticipantProfile.feet) '\(chosenParticipantProfile.inches)"
//            // TODO: location in profile? (DONE)
//            nextVC.locationText.text = chosenParticipantProfile.location
            // TODO: add pfp
        }
    }
    
    // Get all participant data for this event entry in Firestore database.
    // Populate the UI.
    func fetchParticipantData() {
        // for participant table
        db.collection("users").addSnapshotListener {(querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.confirmedParticipants = documents.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
//            self.invitedParticipants = documents.compactMap { (queryDocumentSnapshot) -> User? in
//                return try? queryDocumentSnapshot.data(as: User.self)
//            }
//            self.requestedParticipants = documents.compactMap { (queryDocumentSnapshot) -> User? in
//                return try? queryDocumentSnapshot.data(as: User.self)
//            }
            DispatchQueue.main.async {
                self.participantList.reloadData()
            }
        }
    }
    
    func getDoc() {
        let docRef = db.collection("events").document(documentID)

        docRef.getDocument { (document, error) in
          if let document = document, document.exists {
            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
            print("Document data: \(dataDescription)")
          } else {
            print("Document does not exist")
          }
        }
    }
    
    func fetchEventData() {
        // event data
        db.collection("events").document(documentID)
          .addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
              do {
                  self.event = try document.data(as: Event.self)
                  
                  let ownerDocRef = db.collection("users").document(self.event.owner.documentID)
                  ownerDocRef.getDocument { (document, error) in
                      if let document = document, document.exists {
                          let ownerName = String(describing: document.get("fullName")!)
                          self.eventOwnerLabel.text = ("\(ownerName)'s team: \(self.event.sport)")
                      } else {
                          print("Document does not exist")
                      }
                  }
                  
                  // update UI labels, get participants for event
                  DispatchQueue.main.async {

                      self.locationLabel.text = self.event.locationName
                      self.dateLabel.text = self.reformatDateTime(date:self.event.startTime, format: "EEEE, MMMM dd")
                      self.timeLabel.text = self.reformatDateTime(date: self.event.startTime, format: "h:mm a")
                      self.eventDescription.text = self.event.description
                      self.eventDescription.isEditable = false
                      self.numParticipantsLabel.text = "\(String(self.event.participants!.count)) Participants"
                      self.fetchParticipants()
                      self.participantList.reloadData()
                  }
              }
              catch {
                  print("error")
              }
              guard let data = document.data() else {
              print("Document data was empty.")
              return
            }
            print("Current data: \(data)")
          }
        
    }
    
    func fetchParticipants() {
        // we can use getDocument to access the document referenced by the DocumentReference
        if event != nil && event.participants != nil {
            for docRef in event.participants! {
                docRef.getDocument(as: User.self) { result in
                    do {
                        let value = try result.get()
                        print("Found participant at event \(self.event.name) with value: \(value).")
    
                        DispatchQueue.main.async {
                            // TODO: Figure out how to reload after all events added, not after each event
                            self.participantList.reloadData() // force refresh to see new event
                        }
                    } catch {
                        print("Error retrieving participant at event \(self.event.name): \(error)")
                    }
                }
            }
        }
    }
    
    // returns date/time in format given
    func reformatDateTime(date:Date, format:String) -> String {
        print(date.description)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let output = dateFormatter.string(from: date)
        print("formatted dateTime: \(output)")
        return output
    }
    
    // checks if current user is owner of event & updates userIsEventOwner accordingly
    func checkIfUserIsOwner() {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            print("user id: \(uid)\n")
            print("owner doc ref: \(event.owner.documentID)\n")
            // owner document reference
            // if current user is the owner
            if event.owner.documentID == uid {
                userIsEventOwner = true
                print("user is event owner\n")
            } else {
                userIsEventOwner = false
                print("user is not event owner\n")
            }
        }
    }
    

}
