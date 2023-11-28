//
//  SSSportChooser.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 11/27/23.
//

import UIKit

// TableViewController dedicated to selectable cell from a list. Meant to be used with SSNewPostSportTableViewCell or similar
class SSSportChooser: UITableViewController {
    
    var selectedRowIndex: Int!
    
    var delegate: UIViewController?
    
    var sportChooserCellIdentifier = "SportChooserCellIdentifier"
    
    var sports = [
        "Volleyball (indoor)",
        "Volleyball (sand)",
        "Spikeball",
        "Pickleball",
        "Soccer",
        "Frisbee",
        "Tennis",
        "Racquetball"
    ]
    
    var dismissOnRowSelect = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reusableBasicCellIdentifier")
        
        sports = sports.sorted()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableBasicCellIdentifier", for: indexPath)
        if selectedRowIndex == row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel!.text = sports[row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldSelectedIndex = selectedRowIndex
        selectedRowIndex = indexPath.row
        let otherVC = delegate as! SSSportModifier
        otherVC.changeSport(newSport: sports[selectedRowIndex], newIndex: selectedRowIndex)
        tableView.deselectRow(at: indexPath, animated: true)
        if oldSelectedIndex != -1 {
            tableView.reloadRows(at: [
                IndexPath(row: oldSelectedIndex!, section: 0)
            ], with: .none)
        }
        tableView.reloadRows(at: [
            IndexPath(row: selectedRowIndex, section: 0)
        ], with: .none)
        
        if dismissOnRowSelect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.dismiss(animated: true)
            }
        }
    }
    
}
