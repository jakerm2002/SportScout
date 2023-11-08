//
//  SSEventDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/1/23.
//

import UIKit

class SSEventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var participantCellIdentifier = "SSEventDetailsParticipantCellIdentifier"
    var profileSegueIdentifier = "SegueToSelectedUserProfile"
    
    var event: Event!
    var participantsInEvent: [String: [User]] = [:] // the users in a certain event key must be at that event
    // TODO: Set document ID for event in location VC
    var documentID = "" // will be set from location VC prob
    
    @IBOutlet var eventOwnerLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var eventDescription: UITextView!
    @IBOutlet var numParticipantsLabel: UILabel!
    @IBOutlet var participantList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // TODO: Write functionality
    @IBAction func requestToJoinPressed(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.participants!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: participantCellIdentifier, for: indexPath) as! SSEventDetailsParticipantTableViewCell
        
        let participant = event.participants![indexPath.row]
        
        // TODO: give pfp to participants in list
//        cell.username = participant.
        
        return cell
    }
    
    // TODO: Clicking on a user in participant table will lead to their profile page
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: profileSegueIdentifier, sender: nil)
        
    }
    
    // TODO: populate Profile of user pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegueIdentifier,
           let nextVC = segue.destination as? ProfileViewController
        {
            // TODO: add pfp
        }
    }
    
    // Get all data for this event entry in Firestore database.
    // Populate the UI.
    func fetchData() {
//        db.collection("events").document(documentID)
//            .addSnapshotListener { documentSnapshot, error in
//                guard let document = documentSnapshot else {
//                    print("Error fetching document: \(error!)")
//                    return
//                }
//
//            }
        
        db.collection("events").document(documentID)
          .addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
              do {
                  self.event = try document.data(as: Event.self)
                  // update UI labels, get events for calendar
                  DispatchQueue.main.async {
                  self.eventOwnerLabel.text = ("\(self.event.owner.username)'s team: \(self.event.sport)")
                      self.locationLabel.text = self.event.location
                  self.dateLabel.text = self.reformatDateTime(date:self.event.startTime, format: "EEEE, MMMM dd")
                  self.timeLabel.text = self.reformatDateTime(date: self.event.startTime, format: "h:mm a")
                  self.eventDescription.text = self.event.description
                  self.numParticipantsLabel.text = String(self.event.participants!.count)
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
                        if self.participantsInEvent[self.documentID] != nil {
                            print("Found participant at event \(self.event.name) with value: \(value).")
                            self.participantsInEvent[self.documentID]!.append(value)
                        } else {
                            self.participantsInEvent[self.documentID] = [value]
                        }
    
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
    
    func reformatDateTime(date:Date, format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "format"
        return dateFormatter.string(from: date)
        
    }
    

}
