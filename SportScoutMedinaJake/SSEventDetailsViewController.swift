//
//  SSEventDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/1/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorageUI

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
        
        
        checkIfUserIsOwner() // will show event owner 3 sections in participant table & hide requestToJoinButton
        
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
        fetchEventData {
            self.participantList.reloadData()
        }
    }
    
    // TODO: Write functionality
    @IBAction func requestToJoinPressed(_ sender: Any) {
        let user = Auth.auth().currentUser
        let docuRef = db.collection("users").document(user!.uid)
        if event.confirmedParticipants != nil && event.confirmedParticipants!.contains(docuRef) {
            // show alert so user knows they are a participant
            let controller = UIAlertController(
                title: "Unable To Complete Action",
                message: "You are already a confirmed participant for this event!",
                preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
        } else {
            // send Notification to Event Owner & add them as "requestedParticipant"
            db.collection("events").document(documentID).updateData([
                "requestedParticipants": FieldValue.arrayUnion([docuRef])
            ])
            
            let controller = UIAlertController(
                title: "Request Completed!",
                message: "A request has been sent to the event owner! You will be notified and added as a confirmed participant once the owner accepts.",
                preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
            
            // TODO: Send Notif to Event Owner
//            sendEventOwnerNotif()
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
        
        
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        
        if userIsEventOwner {
            
            var cellUsername = ""
            var cellRealName = ""
            
            switch indexPath.section {
            case confirmedSection:
                cellUsername = confirmedParticipants[indexPath.row].username
                cellRealName = confirmedParticipants[indexPath.row].fullName
                
                if let url = confirmedParticipants[indexPath.row].url {
                    let imgRef = storage.reference().child(url)
                    cell.profilePicture.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "person.crop.circle"))
                }
            case invitedSection:
                cellUsername = invitedParticipants[indexPath.row].username
                cellRealName = invitedParticipants[indexPath.row].fullName
                
                if let url = invitedParticipants[indexPath.row].url {
                    let imgRef = storage.reference().child(url)
                    cell.profilePicture.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "person.crop.circle"))
                }
            case requestedSection:
                cellUsername = requestedParticipants[indexPath.row].username
                cellRealName = requestedParticipants[indexPath.row].fullName
                
                if let url = requestedParticipants[indexPath.row].url {
                    let imgRef = storage.reference().child(url)
                    cell.profilePicture.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "person.crop.circle"))
                }
            default:
                break
            }
            
            cell.username.text = cellUsername
            cell.realName.text = cellRealName
            
        } else {
            
            // show only confirmed participants
            if indexPath.section == confirmedSection {
                cell.username.text = confirmedParticipants[indexPath.row].username
                cell.realName.text = confirmedParticipants[indexPath.row].fullName
                
                if let url = confirmedParticipants[indexPath.row].url {
                    let imgRef = storage.reference().child(url)
                    cell.profilePicture.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "person.crop.circle"))
                }
            }
        }
        return cell
    }
    
    // TODO: Clicking on a user in participant table will lead to their profile page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: profileSegueIdentifier, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return userIsEventOwner
    }
    
    // delete from table
    // TODO: fix functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete && indexPath.section == confirmedSection {
            
            let userToDelete = event.confirmedParticipants![indexPath.row]
            print("deleting \(userToDelete.documentID): e\(confirmedParticipants[indexPath.row])")
            event.confirmedParticipants!.remove(at: indexPath.row)
            
            db.collection("events").document(documentID).updateData(["confirmedParticipants": event.confirmedParticipants!])
            confirmedParticipants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }  else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
            
    }
    
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
           let participantRow = participantList.indexPathForSelectedRow?.row,
           let selectedIndexPath = participantList.indexPathForSelectedRow
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
            
            participantList.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func fetchEventData(completed: @escaping () -> ()) {
        // event data
        db.collection("events").document(documentID)
          .addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return completed()
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
                      self.timeLabel.text = "\(self.reformatDateTime(date: self.event.startTime, format: "h:mm a")) — \(self.reformatDateTime(date: self.event.endTime, format: "h:mm a"))"
                      self.eventDescription.text = self.event.description
                      self.eventDescription.isEditable = false
                      
                      self.fetchParticipants()
                      self.numParticipantsLabel.text = "\(String(self.confirmedParticipants.count)) Confirmed Participants"
//                      self.participantList.reloadData()
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
              completed()
          }
        
    }
    
    func fetchParticipants() {
        // we can use getDocument to access the document referenced by the DocumentReference
        if event != nil {
            if event.confirmedParticipants != nil {
                for docRef in event.confirmedParticipants! {
                    docRef.getDocument(as: User.self) { result in
                        do {
                            let value = try result.get()
                            print("Found confirmed participant at event \(self.event.name) with value: \(value).")
                            
                            if !self.confirmedParticipants.contains(value) {
                                self.confirmedParticipants.append(value)
                            }
                            DispatchQueue.main.async {
                                // TODO: Figure out how to reload after all events added, not after each event
                                self.participantList.reloadData() // force refresh to see new event
                            }
                        } catch {
                            print("Error retrieving confirmed participant at event \(self.event.name): \(error)")
                        }
                    }
                }
            }
            
            if event.invitedParticipants != nil {
                for docRef in event.invitedParticipants! {
                    docRef.getDocument(as: User.self) { result in
                        do {
                            let value = try result.get()
                            print("Found invited participant at event \(self.event.name) with value: \(value).")
                            
                            if !self.invitedParticipants.contains(value) {
                                self.invitedParticipants.append(value)
                            }
                            DispatchQueue.main.async {
                                // TODO: Figure out how to reload after all events added, not after each event
                                self.participantList.reloadData() // force refresh to see new event
                            }
                        } catch {
                            print("Error retrieving invited participant at event \(self.event.name): \(error)")
                        }
                    }
                }
            }
            
            if event.requestedParticipants != nil {
                for docRef in event.requestedParticipants! {
                    docRef.getDocument(as: User.self) { result in
                        do {
                            let value = try result.get()
                            print("Found requested participant at event \(self.event.name) with value: \(value).")
                            
                            if !self.requestedParticipants.contains(value) {
                                self.requestedParticipants.append(value)
                            }
                            DispatchQueue.main.async {
                                // TODO: Figure out how to reload after all events added, not after each event
                                self.participantList.reloadData() // force refresh to see new event
                            }
                        } catch {
                            print("Error retrieving requested participant at event \(self.event.name): \(error)")
                        }
                    }
                }
            }
            
//            self.confirmedParticipants = temp
//            print("\nConfirmed Participants:")
//            for confirmedParticipant in confirmedParticipants {
//                print(confirmedParticipant)
//            }
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
    
    // TODO: Edit so that the event owner gets the notif, not the current user
    func sendEventOwnerNotif() {
        // create content
        let content = UNMutableNotificationContent()
        content.title = "Participant request for: \(event.name)"
        content.subtitle = ""
        content.body = "You have clicked 4 times"
        content.sound = UNNotificationSound.default
        
        // create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // combine it all into a request
        let request = UNNotificationRequest(identifier: "myNotification", content: content, trigger: trigger)
        
        // submit our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
}
