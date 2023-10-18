//
//  SSLocationDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit
import CalendarLib

class SSLocationDetailsViewController: UIViewController, MGCDayPlannerViewDataSource {

    @IBOutlet weak var locationNameTextLabel: UILabel!
    @IBOutlet weak var locationAddrTextLabel: UILabel!
    @IBOutlet weak var locationCityStateZipTextLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var calendarView: MGCDayPlannerView!
    
    
    var LocationObject:Location!
    var documentID = "" // will be set from home VC
    
    var eventsArr:[Event] = []
    var LocationDetailsToNewEventSegueIdentifier = "LocationDetailsToNewEventSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchData()
        locationImageView?.layer.cornerRadius = 5.0
        locationImageView?.layer.masksToBounds = true
        calendarView.dataSource = self
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
    
    // Count events on same day as date
    func dayPlannerView(_ view: MGCDayPlannerView!, numberOfEventsOf type: MGCEventType, at date: Date!) -> Int {
        guard let location = LocationObject else {
            return 0 // Location is not set or is nil
        }
        
        var count = 0
        for event in eventsArr {
            if (Calendar.current.isDate(date, inSameDayAs: event.startTime)) {
                count += 1
            }
        }
        
        return count
    }
    
    func dayPlannerView(_ view: MGCDayPlannerView!, viewForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCEventView! {
        let curEventObj = eventsArr[Int(index)]
        let resultMGCEventView = MGCStandardEventView()

        resultMGCEventView.title = curEventObj.name
        resultMGCEventView.subtitle = curEventObj.sport
        
        return resultMGCEventView
    }
    
    func dayPlannerView(_ view: MGCDayPlannerView!, dateRangeForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCDateRange! {
        // check for errors here incase index out of bounds?
        let curEventObj = eventsArr[Int(index)]
        return MGCDateRange(
            start: curEventObj.startTime,
            end: curEventObj.endTime
        )
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
                        self.fetchEvents()
                        self.calendarView.reloadAllEvents()
                    }
                    
                    self.getImage(url: self.LocationObject.imgPath) { photo in
                        if photo != nil {
                                DispatchQueue.main.async {
                                    self.locationImageView?.image = photo
                                }
                            }
                    }
                    
                    // NEW IDEA: on location details page (this page)
                    // by using the LocationObject.events
                    // simply fetch all of the events here, INSTEAD OF IN THE LOCATION STRUCT
                    // and append to array of events, then use that as our data source
                }
                catch {
                    print("error")
                }
            }
    }
    
    func fetchEvents() {
        // we can use getDocument to access the document referenced by the DocumentReference
        if LocationObject != nil && LocationObject.events != nil {
//            var resultArr: [Event] = []
            
            for docRef in LocationObject.events! {
                docRef.getDocument(as: Event.self) { result in
                    do {
                        let value = try result.get()
                        print("Found event at location \(self.LocationObject.name) with value: \(value).")
//                        resultArr.append(value)
                        self.eventsArr.append(value)
                        DispatchQueue.main.async {
//                            self.eventsArr.append(value)
                            self.calendarView.reloadAllEvents()
                        }
                    } catch {
                        print("Error retrieving event at location \(self.LocationObject.name): \(error)")
                    }
                }
            }
            
//            DispatchQueue.main.async {
//                self.calendarView.reloadAllEvents()
//            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LocationDetailsToNewEventSegueIdentifier,
           let destination = segue.destination as? SSNewEventViewController
        {
            // send the id so that the LocationDetailsVC can load in the data
            destination.documentID = documentID
            destination.locationName = self.LocationObject.name
        }
    }

}
