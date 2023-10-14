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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTableView: UITableView!

    let locationCellIdentifier = "LocationCellIdentifier"
    var locations:[Location] = []
    var picArray:[UIImage] = []
    
    let HomeToLocationDetailsSegueIdentifier = "HomeToLocationDetailsSegueIdentifier"
    
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
            
//            for location in self.locations {
////                let storageRef = storage.reference(withPath: location.imgPath)
//                let storageRef = storage.reference(forURL: location.imgPath)
//                // Download the data, assuming a max size of 1MB (you can change this as necessary)
//                storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//                    if data != nil {
//                        print("adding image for \(location.name)")
//                        // Create a UIImage, add it to the array
//                          let pic = UIImage(data: data!)
//                          self.picArray.append(pic!)
//                    } else {
//                        print("error fetching image for location with name \(location.name): \(error?.localizedDescription)")
//                    }
//                }
//            }
            
            print(self.locations[0].imgPath)
            
            // update table view
            DispatchQueue.main.async {
                self.homeTableView.reloadData()
            }
        }
    }
    
//    func fetchImages() {
//        for location in self.locations {
//            //                let storageRef = storage.reference(withPath: location.imgPath)
//            let storageRef = storage.reference(forURL: location.imgPath)
//            // Download the data, assuming a max size of 1MB (you can change this as necessary)
//            storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//                if data != nil {
//                    print("adding image for \(location.name)")
//                    // Create a UIImage, add it to the array
//                    let pic = UIImage(data: data!)
//                    self.picArray.append(pic!)
//                } else {
//                    print("error fetching image for location with name \(location.name): \(error?.localizedDescription)")
//                }
//            }
//        }
//        print(self.picArray.description)
//        // update table view
//        DispatchQueue.main.async {
//            self.homeTableView.reloadData()
//        }
//    }
    
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
    
//    func getImage(url: String, completion: @escaping (UIImage?) -> ()) {
//        URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
//            if error == nil {
//                completion(UIImage(data: data!))
//            } else {
//                completion(nil)
//            }
//        }.resume()
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        print("generating cell for row \(row)")
        cell.textLabel?.text = locations[row].name
        cell.detailTextLabel?.text = locations[row].addr_field_1
        
        cell.tag += 1
        let tag = cell.tag
        
//        cell.imageView?.image = UIImage(named: "\(images[row])")
        if picArray.indices.contains(row) {
            print("seeing image for row \(row)")
            cell.imageView?.image = picArray[row]
        }
//        cell.imageView?.image = picArray[row]
        
        let photoUrl = locations[row].imgPath
        getImage(url: photoUrl) { photo in
            if photo != nil {
                if cell.tag == tag {
                    DispatchQueue.main.async {
                        cell.imageView?.image = photo
                        cell.layoutSubviews() // refreshed cell will check for imageView so that the UIImageView will appear
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
        if segue.identifier == HomeToLocationDetailsSegueIdentifier,
           let destination = segue.destination as? SSLocationDetailsViewController,
           let index = homeTableView.indexPathForSelectedRow?.row
        {
            // send the id so that the LocationDetailsVC can load in the data
            destination.documentID = locations[index].id!
        }
    }
    

}
