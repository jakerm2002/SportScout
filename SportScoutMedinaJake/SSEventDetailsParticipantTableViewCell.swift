//
//  SSEventDetailsParticipantTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Ashley Nicole Yude on 11/3/23.
//

import UIKit

class SSEventDetailsParticipantTableViewCell: UITableViewCell {
    
    @IBOutlet var profilePicture: UIView!
    @IBOutlet var username: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
