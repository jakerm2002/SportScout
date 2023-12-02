//
//  CustomizeSportViewController.swift
//  SportScoutMedinaJake
//
//  Created by Joshua Chen on 11/29/23.
//

import UIKit

class CustomizeSportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sportsTableView: UITableView!
    
    var delegate: UIViewController?
    
    let SportOptionCellIdentifier = "SportOptionCellIdentifier"
    
    var selectedRowIndex:[Int] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sports = sports.sorted()
        // Do any additional setup after loading the view.
        sportsTableView.dataSource = self
        sportsTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: SportOptionCellIdentifier, for: indexPath)
        if selectedRowIndex.contains(row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel!.text = sports[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRowIndex.contains(indexPath.row) {
            sportsTableView.deselectRow(at: indexPath, animated: true)
            selectedRowIndex.remove(at: selectedRowIndex.firstIndex(of: indexPath.row)!)
            sportsTableView.reloadRows(at: [
                IndexPath(row: indexPath.row, section: 0)
            ], with: .automatic)
        } else {
            selectedRowIndex.append(indexPath.row)
            
            sportsTableView.reloadRows(at: [
                IndexPath(row: indexPath.row, section: 0)
            ], with: .automatic)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let otherVC = delegate as! addSportText
        var text = ""
        for row in selectedRowIndex {
            if text == "" {
                text.append(sports[row])
            } else {
                text.append(", " + sports[row])
            }
        }
        otherVC.addSportText(newSport: text)
        dismiss(animated: true)
    }
    
}
