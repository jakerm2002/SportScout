//
//  HomeViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

public let names = ["Gregory Gym", "Recreational Sports Center", "Northwest Recreation Center", "Austin Recreation Center", "Hancock Recreation Center"]
public let images = ["gregGym", "recSports", "northwestRec", "austinRec", "hancockRec"]
public let addresses = ["2100 Speedway", "2001 San Jacinto Blvd", "2913 Northland Dr", "1301 Shoal Creek Blvd", "811 E 41st St"]


let db = Firestore.firestore()

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTableView: UITableView!

    let locationCellIdentifier = "LocationCellIdentifier"
    var locations:[Location] = []
    
    let HomeToLocationDetailsSegueIdentifier = "HomeToLocationDetailsSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        fetchData()
    }
    
    // get locations and refresh table view
    func fetchData() {
        db.collection("Locations").addSnapshotListener { (querySnapshot, error) in
          guard let documents = querySnapshot?.documents else {
            print("No documents")
            return
          }
            
            // convert each database entry into Location object
            // add to locations array
          self.locations = documents.compactMap { queryDocumentSnapshot -> Location? in
            return try? queryDocumentSnapshot.data(as: Location.self)
          }
            
            // update table view
            DispatchQueue.main.async {
                self.homeTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 2
//    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = locations[row].name
        cell.detailTextLabel?.text = locations[row].addr_field_1
        
//        cell.imageView?.image = UIImage(named: "\(images[row])")
        
        cell.imageView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
//        let vertSpace = (NSLayoutConstraint(
//            item: cell.imageView!,
//            attribute: .top,
//            relatedBy: .equal,
//            toItem: cell.contentView,
//            attribute: .bottom,
//            multiplier: 1,
//            constant: 0))
//        NSLayoutConstraint.activate([vertSpace])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == HomeToLocationDetailsSegueIdentifier,
           let destination = segue.destination as? SSLocationDetailsViewController,
           let index = homeTableView.indexPathForSelectedRow?.row
        {
            // send the id so that the LocationDetailsVC can load in the data
            destination.documentID = locations[index].id!
        }
    }
    

}
