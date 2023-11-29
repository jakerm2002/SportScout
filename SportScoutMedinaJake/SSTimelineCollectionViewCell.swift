//
//  SSTimelineCollectionViewCell.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/24/23.
//

import UIKit

class SSTimelineCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var authorUsernameLabel: UILabel!
    @IBOutlet weak var authorProfileImage: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var captionLabel: UITextView!
    @IBOutlet weak var sportLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var mediaView: SSTimelinePostMediaView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    var hasMedia: Bool = false
    
    var cornerRadius: CGFloat = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
        // Apply rounded corners to contentView
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        layer.backgroundColor = UIColor.purple.cgColor
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        // Apply a shadow
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.35
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        
        // circular profile picture
        authorProfileImage.layer.cornerRadius = authorProfileImage.bounds.height / 2
        authorProfileImage.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Improve scrolling performance with an explicit shadowPath
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
}
