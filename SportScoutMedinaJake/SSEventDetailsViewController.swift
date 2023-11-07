//
//  SSEventDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/1/23.
//

import UIKit

class SSEventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var event: Event!
    @IBOutlet var eventOwnerLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var eventDescription: UITextView!
    @IBOutlet var numParticipantsLabel: UILabel!
    @IBOutlet var participantList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func requestToJoinPressed(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.participants!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    

}
