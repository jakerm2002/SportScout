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

class SSLocationDetailsViewController: UIViewController, MGCDayPlannerViewDataSource, MGCDayPlannerViewDelegate {
    
    @IBOutlet weak var locationNameTextLabel: UILabel!
    @IBOutlet weak var locationAddrTextLabel: UILabel!
    @IBOutlet weak var locationCityStateZipTextLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var calendarView: MGCDayPlannerView!
    
    var LocationObject:Location!
    
    var eventsOnDate: [Date: [Event]] = [:] // the events under a certain date key must occur on that date
    var documentID = "" // will be set from home VC
    
    var selectedEventDate: Date?
    var selectedEventIndex: UInt = 0
    
    var LocationDetailsToSelectedEventSegueIdentifier = "LocationDetailsToSelectedEventSegueIdentifier"
    var LocationDetailsToNewEventSegueIdentifier = "LocationDetailsToNewEventSegueIdentifier"
    
    // dummy start date where some of our dummy events are happening
    var exampleStartDateForCalendar:NSDate = NSDate(timeIntervalSince1970: TimeInterval(1697812200))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        calendarView.showsAllDayEvents = false
        calendarView.eventIndicatorDotColor = UIColor(.red)
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.backgroundColor = .white
        calendarView.daySeparatorsColor = .systemGray
        calendarView.timeSeparatorsColor = .systemGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // TODO: Enable this feature only when accessing a location from the home page (list of locations page)
        // If coming to back to the view from the NewEventVC or EventVC, the calendar freezes and is not scrollable
        
        // move the calendar to dummy start date where all of our dummy events are
        // calendarView.scroll(to: exampleStartDateForCalendar as Date, options: .dateTime, animated: true)
    }
    
    // get a color for an event on the calendar
    func selectEventViewColor(forIndex idx: UInt) -> UIColor {
        // make this implementation better later,
        // try to avoid having the same color next to each other
        // maybe assign color by sport or start time?
        // var index = Int(idx)
        return eventViewColors.randomElement()!
    }
    
    // https://stackoverflow.com/questions/35392538/remove-time-from-a-date-like-this-2016-02-10-000000
    func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    // Custom calendar protocol function: Count events on same day as date
    func dayPlannerView(_ view: MGCDayPlannerView!, numberOfEventsOf type: MGCEventType, at date: Date!) -> Int {
        guard LocationObject != nil else {
            return 0 // Location is not set or is nil
        }

        let dateWithoutTime = self.removeTimeStamp(fromDate: date)
        
        if let eventsOnDay = self.eventsOnDate[dateWithoutTime] {
            print("service called numberOfEventsOf for:\n\ttype: \(type.rawValue)\t\n\tdate: \(date.description)\n\tvalue returned: \(eventsOnDay.count)")
            return eventsOnDay.count
        } else {
            print("service called numberOfEventsOf for:\n\ttype: \(type.rawValue)\t\n\tdate: \(date.description)\n\tvalue returned: 0")
            return 0
        }
    }
    
    // Custom calendar protocol function: returns a View for a specific event
    func dayPlannerView(_ view: MGCDayPlannerView!, viewForEventOf type: MGCEventType, at index: UInt, date: Date!) -> MGCEventView! {
        let dateWithoutTime = self.removeTimeStamp(fromDate: date)
        let curEventObj = eventsOnDate[dateWithoutTime]![Int(index)]

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
        let dateWithoutTime = self.removeTimeStamp(fromDate: date)
        let curEventObj = eventsOnDate[dateWithoutTime]![Int(index)]
        
        return MGCDateRange(
            start: curEventObj.startTime,
            end: curEventObj.endTime
        )
    }
    
    func dayPlannerView(_ view: MGCDayPlannerView!, didSelectEventOf type: MGCEventType, at index: UInt, date: Date!) {
        let dateWithoutTime = self.removeTimeStamp(fromDate: date)
        let curEventObj = eventsOnDate[dateWithoutTime]![Int(index)]
        print("Calendar detected event selection:\n\tTitle: \(curEventObj.name)\n\tLocation: \(curEventObj.location)\n\tSport: \(curEventObj.sport)\n\tStart time (UTC): \(curEventObj.startTime.description)\n\tEnd time (UTC): \(curEventObj.endTime.description)\n\tDescription: \(curEventObj.description)")
        
        selectedEventDate = date
        selectedEventIndex = index
        
        calendarView.deselectEvent()
        // TODO: perform a segue to the event/game page and send over the data from the selected event.
        performSegue(withIdentifier: LocationDetailsToSelectedEventSegueIdentifier, sender: nil)
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
                        self.locationNameTextLabel.text = self.LocationObject.name
                        self.locationAddrTextLabel.text = self.LocationObject.addr_field_1
                        self.locationCityStateZipTextLabel.text = "\(self.LocationObject.city) \(self.LocationObject.state), \(self.LocationObject.zip)"
                        
                        Task {
                            await self.fetchEvents()
                        }
                    
                    let url = self.LocationObject.imgPath
                    let imgRef = storage.reference(forURL: url)
                    self.locationImageView.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "photo"))
                }
                catch {
                    print("error")
                }
            }
    }
    
    // Get all the events scheduled at this location.
    @MainActor
    func fetchEvents() async {
        eventsOnDate.removeAll()
        // we can use getDocument to access the document referenced by the DocumentReference
        if LocationObject != nil && LocationObject.events != nil {
            for docRef in LocationObject.events! {
                docRef.getDocument(as: Event.self) { result in
                    do {
                        let value = try result.get()
                         print("Found event at location \(self.LocationObject.name) with value: \(value).")
                        let dateWithoutTime = self.removeTimeStamp(fromDate: value.startTime)
                        if self.eventsOnDate[dateWithoutTime] != nil {
                            // https://stackoverflow.com/a/24535563
                            // by using the below syntax, we can mutate the array directly.
                            self.eventsOnDate[dateWithoutTime]!.append(value)
                        } else {
                            self.eventsOnDate[dateWithoutTime] = [value]
                        }
                        self.calendarView.reloadAllEvents()
                    } catch {
                        print("Error retrieving event at location \(self.LocationObject.name): \(error)")
                    }
                }
            }
        }
    }
    
    // For beta version: send data to the New Event screen
    // so it can prepopulate with some data.
    // TODO: send over the location where the Create button was pressed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LocationDetailsToNewEventSegueIdentifier,
           let destination = segue.destination as? SSNewEventViewController
        {
            // send the id so that the NewEventVC can load in the data if necessary
            destination.locationDocumentID = documentID
            destination.locationName = self.LocationObject.name
        } else if segue.identifier == LocationDetailsToSelectedEventSegueIdentifier,
                  let destination = segue.destination as? SSEventDetailsViewController {
            let dateWithoutTime = self.removeTimeStamp(fromDate: selectedEventDate!)
            let curEventObj = eventsOnDate[dateWithoutTime]![Int(selectedEventIndex)]
            
            // populate fields of next VC
            destination.event = curEventObj
//            destination.eventOwnerLabel.text = curEventObj.owner
//            destination.event = curEventObj
            destination.documentID = curEventObj.id!
               }
    }
    
}
