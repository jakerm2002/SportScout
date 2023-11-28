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
    
    let sportChooserCellIdentifier = "SportChooserCellIdentifier"
    
    var dismissOnRowSelect = false
    
    var items: [String]?
    
    let noItemsErrorMsg = "SSSportChooser must be assigned an array of items to display."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reusableBasicCellIdentifier")
        
        guard items != nil else { print(noItemsErrorMsg); fatalError(noItemsErrorMsg) }
        items = items!.sorted()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard items != nil else {
            print(noItemsErrorMsg)
            return 0
        }
        return items!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableBasicCellIdentifier", for: indexPath)
        if selectedRowIndex == row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if let items = items {
            cell.textLabel!.text = items[row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldSelectedIndex = selectedRowIndex
        selectedRowIndex = indexPath.row
        let otherVC = delegate as! SSSportModifier
        guard items != nil else { print(noItemsErrorMsg); return }
        otherVC.changeSport(newSport: items![selectedRowIndex], newIndex: selectedRowIndex)
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
