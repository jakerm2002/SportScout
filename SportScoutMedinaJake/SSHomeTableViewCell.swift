//
//  SSHomeTableViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/21/23.
//

import UIKit

class SSHomeTableViewCell: UITableViewCell {
    @IBOutlet weak var locationTitleTextLabel: UILabel!
    @IBOutlet weak var locationAddressTextLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    // Rounded corners and drop shadow for table view cells
    // https://stackoverflow.com/questions/37645408/uitableviewcell-rounded-corners-and-shadow
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace: CGFloat = 5.0
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0))
        
        // add shadow on cell
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.23
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        
        // add corner radius on `contentView`
        self.contentView.backgroundColor = .secondarySystemBackground
        self.contentView.layer.cornerRadius = 8
        
        locationImageView.layer.cornerRadius = 5.0
        locationImageView.layer.masksToBounds = true
    }
}
