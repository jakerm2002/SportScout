//
//  SSLocationDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit

class SSLocationDetailsViewController: UIViewController {

    @IBOutlet weak var locationNameTextLabel: UILabel!
    @IBOutlet weak var locationAddrTextLabel: UILabel!
    @IBOutlet weak var locationCityStateZipTextLabel: UILabel!
    
    var LocationObject:Location!
    var documentID = "" // will be set from home VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
    }
    
    func fetchData() {
        db.collection("Locations").document(documentID)
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
                
                // once we had the document data, put it into our Location object
                do {
                    self.LocationObject = try document.data(as: Location.self)
                    // update labels
                    DispatchQueue.main.async {
                        self.locationNameTextLabel.text = self.LocationObject.name
                        self.locationAddrTextLabel.text = self.LocationObject.addr_field_1
                        self.locationCityStateZipTextLabel.text = "\(self.LocationObject.city) \(self.LocationObject.state), \(self.LocationObject.zip)"
                    }
                }
                catch {
                    print("error")
                }
            }
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
