//
//  SSEventDetailsParticipantTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Ashley Nicole Yude on 11/3/23.
//

import UIKit

class SSEventDetailsParticipantTableViewCell: UITableViewCell {
    
    var participantType:String?
    
    @IBOutlet var profilePicture: UIView!
    @IBOutlet var username: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // rounded image view to store pfp
        self.imageView!.layer.cornerRadius =
        self.imageView!.frame.size.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
