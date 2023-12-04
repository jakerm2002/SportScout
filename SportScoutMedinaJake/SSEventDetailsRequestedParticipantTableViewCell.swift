//
//  SSEventDetailsRequestedParticipantTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 12/4/23.
//

import UIKit

class SSEventDetailsRequestedParticipantTableViewCell: SSEventDetailsParticipantTableViewCell {
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        acceptButton.layer.cornerRadius = acceptButton.bounds.height / 2
        acceptButton.layer.masksToBounds = true
        
        declineButton.layer.cornerRadius = declineButton.bounds.height / 2
        declineButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func acceptButtonPressed(_ sender: Any) {
        print("SSEventDetailsRequestedParticipantTableViewCell: Accept button pressed")
        guard acceptCallback != nil else {
            fatalError("no callback function passed in")
        }
        acceptCallback!()
    }
    
    @IBAction func declineButtonPressed(_ sender: Any) {
        print("SSEventDetailsRequestedParticipantTableViewCell: Decline button pressed")
        guard declineCallback != nil else {
            fatalError("no callback function passed in")
        }
        declineCallback!()
    }
}
