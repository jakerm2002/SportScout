//
//  SSNewEventViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit

protocol SportChanger {
    func changeSport(newSport: String, newIndex: Int)
}

class SSNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SportChanger {
    func changeSport(newSport: String, newIndex: Int) {
        let sportIndexPath = IndexPath(row: 2, section: 0)
        let sportCell = newEventTableView.cellForRow(at: sportIndexPath) as! SSNewEventSportTableViewCell
        sportCell.selectedSportLabel.text = newSport
        sportCell.selectedSportIndex = newIndex
//        newEventTableView.reloadRows(at: [sportIndexPath], with: .automatic)
    }
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEventTableView.delegate = self
        newEventTableView.dataSource = self
        // print(documentID)
        // print(locationName)
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
            
            let newEvent = Event(name: nameCell.titleTextField.text!,
                                 location: locationCell.locationTextField.text!,
                                 sport: sportCell.selectedSportLabel.text!,
                                 startTime: startsAtCell.startsAtDatePicker.date,
                                 endTime: endsAtCell.endsAtDatePicker.date,
                                 description: descriptionCell.descriptionTextField.text!
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
    
    // TODO: send over the location where the Create button was pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SSChooseSportSegue,
           let nextVC = segue.destination as? SSChooseSportViewController
        {
            let sportIndexPath = IndexPath(row: 2, section: 0)
            let sportCell = newEventTableView.cellForRow(at: sportIndexPath) as! SSNewEventSportTableViewCell
            nextVC.delegate = self
            nextVC.selectedRowIndex = sportCell.selectedSportIndex
        }
    }
}
