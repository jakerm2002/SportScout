//
//  SSLocationDetailsViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import UIKit
import CalendarLib

// might reuse later
// let eventViewColors:[UIColor] = [
//     UIColor(red: 0.80, green: 0.45, blue: 0.88, alpha: 1.00),
//     UIColor(red: 0.40, green: 0.86, blue: 0.22, alpha: 1.00),
//     UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.00),
//     UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.00),
// ]

// different calendar colors, similar to those in the macOS Calendar app
let eventViewColors:[UIColor] = [
    UIColor(red: 0.69, green: 0.29, blue: 0.79, alpha: 1.00),
    UIColor(red: 0.29, green: 0.75, blue: 0.12, alpha: 1.00),
    UIColor(red: 0.88, green: 0.67, blue: 0.00, alpha: 1.00),
    UIColor(red: 1.00, green: 0.50, blue: 0.00, alpha: 1.00)
]

class SSLocationDetailsViewController: UIViewController, MGCDayPlannerViewDataSource {
    
    @IBOutlet weak var locationNameTextLabel: UILabel!
    @IBOutlet weak var locationAddrTextLabel: UILabel!
    @IBOutlet weak var locationCityStateZipTextLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var calendarView: MGCDayPlannerView!
    
    var LocationObject:Location!
    
    // TODO: Change the structure of eventsArr to:
    // eventsArr: [Date: [Event]]
    // where the events under a certain date key
    // must occur on that date
    
    var eventsArr:[Event] = []
    var documentID = "" // will be set from home VC
    
    var LocationDetailsToNewEventSegueIdentifier = "LocationDetailsToNewEventSegueIdentifier"
    
    // dummy start date where some of our dummy events are happening
    var exampleStartDateForCalendar:NSDate = NSDate(timeIntervalSince1970: TimeInterval(1697812200))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        calendarView.showsAllDayEvents = false
        calendarView.eventIndicatorDotColor = UIColor(.red)
        calendarView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // move to dummy start date
        calendarView.scroll(to: exampleStartDateForCalendar as Date, options: .dateTime, animated: true)
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
    
    // get a color for an event on the calendar
    func selectEventViewColor(forIndex idx: UInt) -> UIColor {
        // make this implementation better later,
        // try to avoid having the same color next to each other
        // maybe assign color by sport or start time?
        // var index = Int(idx)
        return eventViewColors.randomElement()!
    }
    
    // Custom calendar protocol function: Count events on same day as date
    func dayPlannerView(_ view: MGCDayPlannerView!, numberOfEventsOf type: MGCEventType, at date: Date!) -> Int {
        guard LocationObject != nil else {
            return 0 // Location is not set or is nil
        }
        
        var count = 0
        for event in eventsArr {
            if (Calendar.current.isDate(date, inSameDayAs: event.startTime)) {
                count += 1
            }
        }
        print("service called numberOfEventsOf for:\n\ttype: \(type.rawValue)\t\n\tdate: \(date.description)\n\tvalue returned: \(count)")
        return count
    }
    
    // Custom calendar protocol function: returns a View for a specific event
    func dayPlannerView(_ view: MGCDayPlannerView!, viewForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCEventView! {
        let curEventObj = eventsArr[Int(index)] // the Event object we need to look at

        view.register(MGCStandardEventView.self, forEventViewWithReuseIdentifier: "SSCalendarEventViewIdentifier")
        let resultMGCEventView = view.dequeueReusableView(withIdentifier: "SSCalendarEventViewIdentifier", forEventOf: type, at: index, date: date) as! MGCStandardEventView
        resultMGCEventView.title = curEventObj.name
        resultMGCEventView.subtitle = curEventObj.sport
        resultMGCEventView.color = selectEventViewColor(forIndex: index)
        return resultMGCEventView
    }
    
    // Custom calendar protocol function: returns the date range for a specific event
    func dayPlannerView(_ view: MGCDayPlannerView!, dateRangeForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCDateRange! {
        print("service called dateRangeForEventOf for:\n\ttype: \(type.rawValue)\n\tindex: \(index)\n\tdate: \(date.description)")
        // TODO: get only the events that are on this date?? figure out how index arg works
        // TODO: check for index out of bounds
        let curEventObj = eventsArr[Int(index)] // the Event object we need to look at
        
        return MGCDateRange(
            start: curEventObj.startTime,
            end: curEventObj.endTime
        )
    }
    
    // Get all data for this location entry in Firestore database.
    // Populate the UI.
    func fetchData() {
        db.collection("Locations").document(documentID)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                do {
                    self.LocationObject = try document.data(as: Location.self)
                    // update UI labels, get events for calendar
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
                }
                catch {
                    print("error")
                }
            }
    }
    
    // Get all the events scheduled at this location.
    func fetchEvents() {
        // we can use getDocument to access the document referenced by the DocumentReference
        if LocationObject != nil && LocationObject.events != nil {
            for docRef in LocationObject.events! {
                docRef.getDocument(as: Event.self) { result in
                    do {
                        let value = try result.get()
                        // print("Found event at location \(self.LocationObject.name) with value: \(value).")
                        self.eventsArr.append(value)
                        DispatchQueue.main.async {
                            // TODO: Figure out how to reload after all events added, not after each event
                            self.calendarView.reloadAllEvents() // force refresh to see new event
                        }
                    } catch {
                        print("Error retrieving event at location \(self.LocationObject.name): \(error)")
                    }
                }
            }
        }
    }
    
    // For beta version: send data to the New Event screen
    // so it can prepopulate with some data.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LocationDetailsToNewEventSegueIdentifier,
           let destination = segue.destination as? SSNewEventViewController
        {
            // send the id so that the NewEventVC can load in the data if necessary
            destination.documentID = documentID
            destination.locationName = self.LocationObject.name
        }
    }
    
}
