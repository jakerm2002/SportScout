//
//  ProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var sportsText: UILabel!
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView = UIImageView(image: UIImage(named: "recSports"))
        imageView.frame = CGRect(x: 0, y: 0, width: 144, height: 144)

        horizontalScrollView.backgroundColor = UIColor.white
        horizontalScrollView.contentSize = CGSize(width: 360, height: 144)
        for _ in 1...10 {
            horizontalScrollView.addSubview(imageView)
        }
        horizontalScrollView.delegate = self
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
