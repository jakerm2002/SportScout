//
//  SSSettingsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase

public let notificationSettings = ["On", "Off"]
public let faqQuestionsAnswers = ["Q1 - How to set up an event?", "Answer1", "Q2", "Answer2", "Q3", "Answer3"]

class SSSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var settingsTableView: UITableView!
    
    let logoutSegueIdentifier = "LogoutSegue"
    var notifStatus = true
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notificationSettings.count
        } else {
            return faqQuestionsAnswers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row = indexPath.row
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = notificationSettings[row]
            if (row == 0 && notifStatus || row == 1 && !notifStatus) {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        } else {
            cell.textLabel?.text = faqQuestionsAnswers[row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // checkmarks for notification settings
        if indexPath.section == 0 {
            if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.none {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
                if (notifStatus) {
                    notifStatus = false
                } else {
                    notifStatus = true
                }
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Notification Settings"
        } else {
            return "Frequently Asked Questions"
        }
    }
    
    // fix the first header text is getting cut off at the top
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return section == 0 ? 20 : 18
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutButtonPressed(_ sender: Any) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            performSegue(withIdentifier: logoutSegueIdentifier, sender: self)
        } catch let signOutError {
            print(signOutError.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == logoutSegueIdentifier {
            guard let vc = segue.destination as? LoginViewController else { return }
        }
    }
}
