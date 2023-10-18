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

// globals for Firestore
let db = Firestore.firestore()
let storage = Storage.storage()

// TODO: Move to its own file
class SSHomeTableViewCell: UITableViewCell {
    @IBOutlet weak var locationTitleTextLabel: UILabel!
    @IBOutlet weak var locationAddressTextLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    // Rounded corners and drop shadow for table view cells
    // https://stackoverflow.com/questions/37645408/uitableviewcell-rounded-corners-and-shadow
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace: CGFloat = 10.0
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bottomSpace, right: 0))
        
        // add shadow on cell
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.23
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        
        // add corner radius on `contentView`
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 8
    }
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var locations:[Location] = []
    
    var leftNavBarSegment = UISegmentedControl(items: ["Map", "List"])
    var searchBar = UISearchBar()
    
    // the custom cell on the storyboard
    let customLocationCellIdentifier = "CustomLocationCellIdentifier"
    let customLocationCellToLocationDetailsSegueIdentifier = "CustomLocationCellToLocationDetailsSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        // UI styling
        homeTableView.separatorStyle = .none
        homeTableView.clipsToBounds = false
        searchBar.sizeToFit()
        
        fetchData()
        
        // Segmented control styling.
        leftNavBarSegment.selectedSegmentIndex = 1
        leftNavBarSegment.selectedSegmentTintColor = UIColor(red: 0.36, green: 0.35, blue: 0.56, alpha: 1.00)
        // make segmented control text white for selected segment
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        leftNavBarSegment.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        // add segmented control and search bar to navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftNavBarSegment)
        navigationItem.titleView = searchBar
    }
    
    // Get all locations from Firestore and refresh table view.
    func fetchData() {
        db.collection("Locations").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            // Convert each location DB entry into Location object,
            // add to locations array.
            self.locations = documents.compactMap { queryDocumentSnapshot -> Location? in
                // TODO: catch possible errors with the SSModels here
                return try? queryDocumentSnapshot.data(as: Location.self)
            }
            
            // update table view
            DispatchQueue.main.async {
                self.homeTableView.reloadData()
                // print(self.locations.debugDescription)
            }
        }
    }
    
    // unused; placeholder img to use before img loading finished
    static func image(fromColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fill(rect)
        }
        return img
    }
    
    // retrieve an image from Firestore and execute a function once finished
    func getImage(url: String, completion: @escaping (UIImage?) -> ()) {
        let storageRef = storage.reference(forURL: url)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Additional corner/shadow styling for table view cells.
    // https://stackoverflow.com/questions/37645408/uitableviewcell-rounded-corners-and-shadow
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        
        // TODO: removing this line makes the drop shadow less wonky
        // TODO: but breaks smooth scrolling
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customLocationCellIdentifier, for: indexPath as IndexPath) as! SSHomeTableViewCell
        
        let row = indexPath.row
        // print("generating cell for row \(row)")
        cell.locationTitleTextLabel?.text = locations[row].name
        cell.locationAddressTextLabel?.text = locations[row].addr_field_1
        
        // Retrieve the cell's image.
        // This works for dummy data, but, in the future,
        // images might seem like they load slowly when
        // scrolling due to the cellForRowAt function only
        // being called when a cell is becoming visible.
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
        return cell
    }
    
    // Segue to the selected location's details page.
    // Send Firestore document ID to LocationDetailsVC so it can fetch data.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == customLocationCellToLocationDetailsSegueIdentifier,
           let destination = segue.destination as? SSLocationDetailsViewController,
           let index = homeTableView.indexPathForSelectedRow?.row
        {
            destination.documentID = locations[index].id!
        }
    }
    
}
