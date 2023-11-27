//
//  SSVideoButton.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/27/23.
//

import UIKit

class SSVideoButton: UIButton {

    var label: UILabel!
    var image: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit(){
        let frameCenterX = frame.width / 2 - (50/2)
        let frameCenterY = frame.height / 2 - (50/2)
        label = UILabel(frame: CGRect(x: frameCenterX, y: frameCenterY + 20, width: 50, height: 50))
        image = UIImageView(frame: CGRect(x: frameCenterX, y: frameCenterY - 20, width: 50, height: 50))
        
        label.textAlignment = .center
        label.text = "Video"
        label.textColor = .systemBlue
        image.contentMode = .scaleAspectFit
        image.image = UIImage(systemName: "video.fill")
        
        addSubview(label)
        addSubview(image)
    }

}
