//
//  SSNewEventViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit

class SSNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEventTableView.delegate = self
        newEventTableView.dataSource = self
        // print(documentID)
        // print(locationName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 // hardcoded number of cells
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
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventSportCellIdentifier, for: indexPath)
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
        let sportCell = newEventTableView.cellForRow(at: IndexPath(row: 2, section: 0))
        
        let startsAtCell = newEventTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SSNewEventStartsAtTableViewCell
        
        let endsAtCell = newEventTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! SSNewEventEndsAtTableViewCell
        
        let descriptionCell = newEventTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as! SSNewEventDescriptionTableViewCell
        
        let newEvent = Event(name: nameCell.titleTextField.text!,
                             location: locationCell.locationTextField.text!,
                             sport: "Volleyball",
                             startTime: startsAtCell.startsAtDatePicker.date,
                             endTime: endsAtCell.endsAtDatePicker.date,
                             description: descriptionCell.descriptionTextField.text!
        )
        
        // TODO: Validate input
        
        // let document ID be auto-generated
        do {
//            try db.collection("events").document().setData(from: newEvent)
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
