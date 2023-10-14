//
//  HomeViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

public let names = ["Gregory Gym", "Recreational Sports Center", "Northwest Recreation Center", "Austin Recreation Center", "Hancock Recreation Center"]
public let images = ["gregGym", "recSports", "northwestRec", "austinRec", "hancockRec"]
public let addresses = ["2100 Speedway", "2001 San Jacinto Blvd", "2913 Northland Dr", "1301 Shoal Creek Blvd", "811 E 41st St"]


let db = Firestore.firestore()
let docRef = db.collection("Locations").document("evFLYvq5Lq5634C5hxsn")

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTableView: UITableView!

    let locationCellIdentifier = "LocationCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
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
        cell.textLabel?.text = names[row]
        cell.detailTextLabel?.text = addresses[row]
        
        cell.imageView?.image = UIImage(named: "\(images[row])")
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
