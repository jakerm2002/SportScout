//
//  SSChooseSportViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/31/23.
//

import UIKit

var sports = [
    "Volleyball (indoor)",
    "Volleyball (sand)",
    "Spikeball",
    "Pickleball",
    "Soccer",
    "Frisbee",
    "Tennis",
    "Racquetball",
    "Basketball"
]

class SSChooseSportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var sportsTableView: UITableView!
    
    var delegate: UIViewController?
    
    let SportOptionCellIdentifier = "SportOptionCellIdentifier"
    
    var selectedRowIndex: Int!
    
//    let selectedCell: UITableViewCell =
    
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
        if selectedRowIndex == row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel!.text = sports[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldSelectedIndex = selectedRowIndex
        selectedRowIndex = indexPath.row
        let otherVC = delegate as! SportChanger
        otherVC.changeSport(newSport: sports[selectedRowIndex], newIndex: selectedRowIndex)
        sportsTableView.deselectRow(at: indexPath, animated: true)
        if oldSelectedIndex != -1 {
            sportsTableView.reloadRows(at: [
                IndexPath(row: oldSelectedIndex!, section: 0)
            ], with: .automatic)
        }
        sportsTableView.reloadRows(at: [
            IndexPath(row: selectedRowIndex, section: 0)
        ], with: .automatic)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        print("setting sport to \(sports[selectedRowIndex-1])")
//        let otherVC = delegate as! SportChanger
//        otherVC.changeSport(newSport: sports[selectedRowIndex - 1], newIndex: selectedRowIndex)
//    }
    

}
