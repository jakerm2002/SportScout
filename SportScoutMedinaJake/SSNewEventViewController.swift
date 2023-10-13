//
//  SSNewEventViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit

class SSNewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var newEventTableView: UITableView!
    
    let NewEventTitleCellIdentifier = "NewEventTitleCellIdentifier"
    let NewEventLocationCellIdentifier = "NewEventLocationCellIdentifier"
    let NewEventDateTimeCellIdentifier = "NewEventDateTimeCellIdentifier"
    let NewEventDescriptionCellIdentifier = "NewEventDescriptionCellIdentifier"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventTitleCellIdentifier, for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewEventLocationCellIdentifier, for: indexPath)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        newEventTableView.delegate = self
        newEventTableView.dataSource = self
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
