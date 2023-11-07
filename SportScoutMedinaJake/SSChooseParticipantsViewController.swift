//
//  SSChooseParticipantsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Ankit Bhattacharyya on 11/7/23.
//

import UIKit

class SSChooseParticipantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var participantsTableView: UITableView!
    var users:[User] = []
    var rowsSelected:[Int] = []
    let participantOptionCellIdentifier = "ParticipantOptionCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        participantsTableView.delegate = self
        participantsTableView.dataSource = self
        fetchData()
        // Do any additional setup after loading the view.
    }

    func fetchData() {
        db.collection("users").addSnapshotListener {(querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            print("queryLength: \(querySnapshot!.documents.count)")
            self.users = documents.compactMap { (queryDocumentSnapshot) -> User? in
                print(queryDocumentSnapshot.data())
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            DispatchQueue.main.async {
                self.participantsTableView.reloadData()
                // print(self.locations.debugDescription)
            }
        }
        print("Users stored: \(self.users.count)")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: participantOptionCellIdentifier, for: indexPath)
        cell.textLabel?.text = users[row].fullName
        cell.detailTextLabel?.text = users[row].username
        if (rowsSelected.contains(row)) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if !rowsSelected.contains(row) {
            rowsSelected.append(row)
        } else {
            if let idx = rowsSelected.firstIndex(where: {$0 == row}) {
                rowsSelected.remove(at: idx)
            }
        }
        participantsTableView.reloadRows(at: [
            IndexPath(row: row, section: 0)
        ], with: .automatic)
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
