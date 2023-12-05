//
//  SSSettingsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase

public let notificationSettings = ["All", "Urgent", "None"]
public let faqQuestions = ["Question 1", "Question 2", "Question 3"]
public let faqAnswer = ["Answer 1", "Answer 2", "Answer 3"]

class SSSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var settingsTableView: UITableView!
    var logoutSegueIdentifier = "LogoutSegue"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notificationSettings.count
        } else {
            return faqQuestions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var row = indexPath.row
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = notificationSettings[row]
        } else {
            cell.textLabel?.text = faqQuestions[row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // checkmarks for notification settings
        if indexPath.section == 0 {
            if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
            
            // todo: only allow one cell to be checkmarked at a time
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Notification Settings"
        } else {
            return "Frequently Asked Questions"
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
