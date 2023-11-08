//
//  SSNewEventViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

protocol SportChanger {
    func changeSport(newSport: String, newIndex: Int)
}

protocol ParticipantsChanger {
    func addParticipant(userId: String)
    func removeParticipant(userId: String)
}

class SSNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SportChanger, ParticipantsChanger {
    
    func addParticipant(userId: String) {
        users.append(userId)
        for userId in users {
            print("Participant: \(userId)")
        }
        numberParticipantsLabel.text = "\(users.count) participants"
    }
    
    func removeParticipant(userId: String) {
        if let idx = users.firstIndex(of: userId) {
            users.remove(at: idx)
        }
        for userId in users {
            print("Participant: \(userId)")
        }
        numberParticipantsLabel.text = "\(users.count) participants"
    }
    
    func changeSport(newSport: String, newIndex: Int) {
        let sportIndexPath = IndexPath(row: 2, section: 0)
        let sportCell = newEventTableView.cellForRow(at: sportIndexPath) as! SSNewEventSportTableViewCell
        sportCell.selectedSportLabel.text = newSport
        sportCell.selectedSportIndex = newIndex
//        newEventTableView.reloadRows(at: [sportIndexPath], with: .automatic)
    }
    
    
    @IBOutlet weak var numberParticipantsLabel: UILabel!
    @IBOutlet weak var newEventTableView: UITableView!
    
    // will be passed in from LocationDetailsVC
    var documentID = ""
    var locationName = ""
    
    let NewEventTitleCellIdentifier = "NewEventTitleCellIdentifier"
    let NewEventLocationCellIdentifier = "NewEventLocationCellIdentifier"
    let NewEventSportCellIdentifier = "NewEventSportCellIdentifier"
    let NewEventStartsAtCellIdentifier = "NewEventStartsAtCellIdentifier"
    let NewEventEndsAtCellIdentifier = "NewEventEndsAtCellIdentifier"
    let NewEventDescriptionCellIdentifier = "NewEventDescriptionCellIdentifier"
    
    let SSNewEventFinishCreationSegue = "SSNewEventFinishCreationSegue"
    let SSChooseSportSegue = "SSChooseSportSegue"
    let SSChooseParticipantsSegue = "SSChooseParticipantsSegue"
    
    var users:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEventTableView.delegate = self
        newEventTableView.dataSource = self
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        newEventTableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // hardcoded number of cells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTitleCellIdentifier, for: indexPath) as! SSNewEventTitleTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventLocationCellIdentifier, for: indexPath) as! SSNewEventLocationTableViewCell
            // TODO: fill in the location from the LocationDetailsVC
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventSportCellIdentifier, for: indexPath) as! SSNewEventSportTableViewCell
            cell.parentVC = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventStartsAtCellIdentifier, for: indexPath) as! SSNewEventStartsAtTableViewCell
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventEndsAtCellIdentifier, for: indexPath) as! SSNewEventEndsAtTableViewCell
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventDescriptionCellIdentifier, for: indexPath) as! SSNewEventDescriptionTableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTitleCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: SSChooseSportSegue, sender: nil)
        }
    }
    
    // TODO: Process/validate data and create event
    // TODO: Segue back to LocationDetailsVC
    @IBAction func createEventButtonPressed(_ sender: Any) {
        // logic
        // create a new event first
        // the event does not necessarily need location reference,
        // but it should probably have it
        
        // the events at a location are stored in an array
        // inside of the Location
        
        // but we might want to access the event's location somewhere else
        // in the app
        
        // TODO: see if we can create a function for this code
        // TODO: or simplify it somehow
        let nameCell = newEventTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SSNewEventTitleTableViewCell
        
        let locationCell = newEventTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SSNewEventLocationTableViewCell
        
        // TODO: Make this of type sport cell
        let sportCell = newEventTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SSNewEventSportTableViewCell
        
        let startsAtCell = newEventTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SSNewEventStartsAtTableViewCell
        
        let endsAtCell = newEventTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! SSNewEventEndsAtTableViewCell
        
        let descriptionCell = newEventTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! SSNewEventDescriptionTableViewCell
        
        var validationErrors: [String] = []
        
        // TODO: Validate input
        if nameCell.titleTextField.text!.isEmpty {
            validationErrors.append("The event is missing a title.")
        }
        
        if sportCell.selectedSportLabel.text! == "None selected" {
            validationErrors.append("The event is missing a sport.")
        }
        
        if !(startsAtCell.startsAtDatePicker.date < endsAtCell.endsAtDatePicker.date) {
            validationErrors.append("The ending date/time must come after the starting date/time.")
        }
        
        if !(endsAtCell.endsAtDatePicker.date.timeIntervalSince(startsAtCell.startsAtDatePicker.date) >= 300) {
            validationErrors.append("The event must last for at least 5 minutes.")
        }
        
        if !validationErrors.isEmpty {
            let alert = UIAlertController(title: "Can't create event", message: "The following information is malformed:", preferredStyle: .alert)
            for err in validationErrors {
                alert.message?.append("\n\u{2022} \(err)")
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            let owner:User = User(bio: "Hi", feet: "6", fullName: "John Smith", inches: "0", sports: "Basketball", username: "jsmith", weight: "160")
            let newEvent = Event(owner: owner,
                                 name: nameCell.titleTextField.text!,
                                 location: locationCell.locationTextField.text!,
                                 sport: sportCell.selectedSportLabel.text!,
                                 startTime: startsAtCell.startsAtDatePicker.date,
                                 endTime: endsAtCell.endsAtDatePicker.date,
                                 description: descriptionCell.descriptionTextField.text!,
                                 participants: fetchUsers(userIds: users)
            )
            
            // let document ID be auto-generated
            do {
                try db.collection("events").document().setData(from: newEvent) {
                    _ in
                    print("New event created successfully in Firestore.")
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let error {
                print("Error creating event in Firestore: \(error.localizedDescription)")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func fetchUsers(userIds: [String]) -> [FirebaseFirestore.DocumentReference] {
        var result:[FirebaseFirestore.DocumentReference] = []
        for userId in userIds {
            let docRef = db.collection("users").document(userId)

            docRef.getDocument { document, error in
              if let error = error as NSError? {
                  print("error")
              }
              else {
                if let document = document {
                    result.append(docRef)
                }
              }
            }
        }
        return result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SSChooseSportSegue,
           let nextVC = segue.destination as? SSChooseSportViewController
        {
            let sportIndexPath = IndexPath(row: 2, section: 0)
            let sportCell = newEventTableView.cellForRow(at: sportIndexPath) as! SSNewEventSportTableViewCell
            nextVC.delegate = self
            nextVC.selectedRowIndex = sportCell.selectedSportIndex
        } else if segue.identifier == SSChooseParticipantsSegue, let nextVC = segue.destination as? SSChooseParticipantsViewController {
            nextVC.navigationItem.title = "Select Participants"
            nextVC.delegate = self
            nextVC.usersSelected = users
        }
    }
    @IBAction func invitePeopleButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: SSChooseParticipantsSegue, sender: nil)
    }
}
