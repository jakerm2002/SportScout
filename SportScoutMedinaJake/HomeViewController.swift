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
import FirebaseStorageUI

// globals for Firestore
let db = Firestore.firestore()
let storage = Storage.storage()

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    var locations:[Location] = []
    var filteredLocations:[Location] = []
    var filtered: Bool = false
    
    var leftNavBarSegment = UISegmentedControl(items: ["Map", "List"])
    var searchBar = UISearchBar()
    
    // the custom cell on the storyboard
    let customLocationCellIdentifier = "CustomLocationCellIdentifier"
    let customLocationCellToLocationDetailsSegueIdentifier = "CustomLocationCellToLocationDetailsSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        searchBar.placeholder = "Filter by location name"
        searchBar.delegate = self
        
        // UI styling
        homeTableView.separatorStyle = .none
        homeTableView.clipsToBounds = false
        searchBar.sizeToFit()
        
        homeTableView.keyboardDismissMode = .onDrag
        
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
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let search = searchBar.text {
            if text.count == 0 {
                filterText(String(search.dropLast()))
            } else {
                filterText(search+text)
            }
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filtered = false
            filteredLocations.removeAll()
            homeTableView.reloadData()
        }
    }
    func filterText(_ query: String) {
        filteredLocations.removeAll()
        for location in locations {
            if location.name.lowercased().contains(query.lowercased()) {
                filteredLocations.append(location)
            }
        }
        homeTableView.reloadData()
        filtered = true
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
        if !filteredLocations.isEmpty {
            return filteredLocations.count
        }
        return filtered ? 0 :locations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
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
        
//        cell.contentView.layer.backgroundColor = UIColor.black.cgColor
        
        let row = indexPath.row
        let location:Location
        if !filteredLocations.isEmpty {
            location = filteredLocations[row]
        } else {
            location = locations[row]
        }
        // print("generating cell for row \(row)")
        cell.locationTitleTextLabel?.text = location.name
        cell.locationAddressTextLabel?.text = location.addr_field_1
        
        // Retrieve the cell's image.
        let url = location.imgPath
        let imgRef = storage.reference(forURL: url)
        cell.locationImageView.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "photo"))
        
        return cell
    }
    
    // Segue to the selected location's details page.
    // Send Firestore document ID to LocationDetailsVC so it can fetch data.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == customLocationCellToLocationDetailsSegueIdentifier,
           let destination = segue.destination as? SSLocationDetailsViewController,
           let index = homeTableView.indexPathForSelectedRow?.row
        {
            if !filteredLocations.isEmpty {
                destination.documentID = filteredLocations[index].id!
            } else {
                destination.documentID = locations[index].id!
            }

        }
    }
    
}
