//
//  SSNewEventSportTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/31/23.
//

import UIKit

class SSNewEventSportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectedSportLabel: UILabel!

    var selectedSportIndex = -1
    var parentVC: UIViewController?
    let SSChooseSportSegue = "SSChooseSportSegue"
    
    @IBAction func chooseSportButtonPressed(_ sender: Any) {
        parentVC!.performSegue(withIdentifier: SSChooseSportSegue, sender: nil)
    }
}
