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
    let NewEventDateTimeCellIdentifier = "NewEventDateTimeCellIdentifier"
    let NewEventDescriptionCellIdentifier = "NewEventDescriptionCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newEventTableView.delegate = self
        newEventTableView.dataSource = self
        // print(documentID)
        // print(locationName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // hardcoded number of cells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTitleCellIdentifier, for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventLocationCellIdentifier, for: indexPath)
            // TODO: fill in the location from the LocationDetailsVC
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventDateTimeCellIdentifier, for: indexPath)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventDescriptionCellIdentifier, for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTitleCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    // TODO: Process/validate data and create event
    // TODO: Segue back to LocationDetailsVC
    @IBAction func createEventButtonPressed(_ sender: Any) {
    }
    
}
