//
//  SSTimelinePostMediaView.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/28/23.
//

import UIKit

class SSTimelinePostMediaView: UIView {

    let imageView = UIImageView()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
//        imageView.contentMode = .scaleAspectFill
//        imageView.sizeThatFits(self.frame.size)
//        imageView.backgroundColor = .red
//        imageView.clipsToBounds = true
//        imageView.frame = self.bounds
//        imageView.contentMode = .scaleAspectFill
//        addSubview(imageView)
    }
//
    override func layoutSubviews() {
//        imageView.backgroundColor = .red
//        imageView.sizeToFit()
//        imageView.contentMode = .scaleAspectFill
    }
    
//    func addImage(image: UIImage) {
//
//        imageView.clipsToBounds = true
//        imageView.frame = self.bounds
//        imageView.contentMode = .scaleAspectFill
//        addSubview(imageView)
//    }
    
    func addImage(imageData: Data) {
        imageView.image = UIImage(data: imageData)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
//
//        self.bounds.size = sizeThatFits(imageView.bounds.size)
//        imageView.frame = self.bounds
//        frame.size.height = 700
        
        addSubview(imageView)
    }

}
