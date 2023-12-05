//
//  SSEventDetailsParticipantTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Ashley Nicole Yude on 11/3/23.
//

import UIKit

class SSEventDetailsParticipantTableViewCell: UITableViewCell {
    
    var participantType:String?
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet weak var realName: UILabel!
    @IBOutlet var username: UILabel!
    
    var acceptCallback: (() -> Void)? = nil
    var declineCallback: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // rounded image view to store pfp
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / 2
        self.profilePicture.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
