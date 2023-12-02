//
//  SSNewPostSportTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/27/23.
//

import UIKit

class SSNewPostSportTableViewCell: UITableViewCell {
 
    // so that the current index can be passed into SSSportChooser
    var selectedSportIndex = -1

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedLabel: UILabel!
    
}
