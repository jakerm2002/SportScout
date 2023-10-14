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
import FirebaseStorage

public let names = ["Gregory Gym", "Recreational Sports Center", "Northwest Recreation Center", "Austin Recreation Center", "Hancock Recreation Center"]
public let images = ["gregGym", "recSports", "northwestRec", "austinRec", "hancockRec"]
public let addresses = ["2100 Speedway", "2001 San Jacinto Blvd", "2913 Northland Dr", "1301 Shoal Creek Blvd", "811 E 41st St"]


let db = Firestore.firestore()
let storage = Storage.storage()

class SSHomeTableViewCell: UITableViewCell {
    @IBOutlet weak var locationTitleTextLabel: UILabel!
    @IBOutlet weak var locationAddressTextLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTableView: UITableView!

    // deprecated: the first prototype cell on the storyboard
    let locationCellIdentifier = "LocationCellIdentifier"
    
    // the new custom cell on the storyboard
    let customLocationCellIdentifier = "CustomLocationCellIdentifier"
    var locations:[Location] = []
    
    let CustomLocationCellToLocationDetailsSegueIdentifier = "CustomLocationCellToLocationDetailsSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        fetchData()
//        fetchImages()
    }
    
    // generate placeholder image
    static func image(fromColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        let renderer = UIGraphicsImageRenderer(bounds: rect)

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fill(rect)
        }

        return img
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
                print(self.locations.description)
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
    
    func getImage(url: String, completion: @escaping (UIImage?) -> ()) {
        let storageRef = storage.reference(forURL: url)
        // Download the data, assuming a max size of 1MB (you can change this as necessary)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if data != nil {
                print("adding image for url \(url)")
                let pic = UIImage(data: data!)
                completion(pic)
            } else {
                print("error fetching image for location with url \(url): \(String(describing: error?.localizedDescription))")
                completion(nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customLocationCellIdentifier, for: indexPath as IndexPath) as! SSHomeTableViewCell
        
        let row = indexPath.row
        print("generating cell for row \(row)")
        cell.locationTitleTextLabel?.text = locations[row].name
        cell.locationAddressTextLabel?.text = locations[row].addr_field_1
        
        
        // retrieve the cell's image
        // this works for dummy data but images
        // might seem like they load slowly when
        // scrolling due to the cellForRowAt function
        // only being called when a cell is becoming visible
        cell.tag += 1
        let tag = cell.tag
        let photoUrl = locations[row].imgPath
        getImage(url: photoUrl) { photo in
            if photo != nil {
                if cell.tag == tag {
                    DispatchQueue.main.async {
                        cell.locationImageView?.layer.cornerRadius = 5.0
                        cell.locationImageView?.layer.masksToBounds = true
                        cell.locationImageView?.image = photo
                    }
                }
            }
        }
        
//        cell.imageView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
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
        if segue.identifier == CustomLocationCellToLocationDetailsSegueIdentifier,
           let destination = segue.destination as? SSLocationDetailsViewController,
           let index = homeTableView.indexPathForSelectedRow?.row
        {
            // send the id so that the LocationDetailsVC can load in the data
            destination.documentID = locations[index].id!
        }
    }
    

}
