//
//  ProfileCalendarViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 12/4/23.
//

import UIKit
import Firebase
import FirebaseStorage
import CalendarLib

class ProfileCalendarViewController: UIViewController, MGCDayPlannerViewDataSource, MGCDayPlannerViewDelegate {
    
    @IBOutlet weak var calendarView: MGCDayPlannerView!
    
    var ProfileCalendarToSelectedEventSegueIdentifier = "ProfileCalendarToSelectedEventSegueIdentifier"
    
    var eventsOnDate: [Date: [Event]] = [:] // the events under a certain date key must occur on that date
    
    var selectedEventDate: Date?
    var selectedEventIndex: UInt = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.showsAllDayEvents = false
        calendarView.eventIndicatorDotColor = UIColor(.red)
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.backgroundColor = .white
        calendarView.daySeparatorsColor = .systemGray
        calendarView.timeSeparatorsColor = .systemGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    func selectEventViewColor(forIndex idx: UInt) -> UIColor {
        return eventViewColors.randomElement()!
    }
    
    func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    func dayPlannerView(_ view: MGCDayPlannerView!, numberOfEventsOf type: MGCEventType, at date: Date!) -> Int {
        let dateWithoutTime = self.removeTimeStamp(fromDate: date)
        
        if let eventsOnDay = self.eventsOnDate[dateWithoutTime] {
            print("service called numberOfEventsOf for:\n\ttype: \(type.rawValue)\t\n\tdate: \(date.description)\n\tvalue returned: \(eventsOnDay.count)")
            return eventsOnDay.count
        } else {
            print("service called numberOfEventsOf for:\n\ttype: \(type.rawValue)\t\n\tdate: \(date.description)\n\tvalue returned: 0")
            return 0
        }
    }
    
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
        performSegue(withIdentifier: ProfileCalendarToSelectedEventSegueIdentifier, sender: nil)
    }
    
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("error getting user")
            return}
        eventsOnDate.removeAll()
        // get all events the user is attending
        let userRef = db.collection("users").document(uid)
        db.collection("events").whereField("confirmedParticipants", arrayContains: userRef)
            .getDocuments() { (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                for docRef in documents {
                    do {
                        let value = try docRef.data(as: Event.self)
                        print(value.name)
                        let dateWithoutTime = self.removeTimeStamp(fromDate: value.startTime)
                        if self.eventsOnDate[dateWithoutTime] != nil {
                            // https://stackoverflow.com/a/24535563
                            // by using the below syntax, we can mutate the array directly.
                            self.eventsOnDate[dateWithoutTime]!.append(value)
                        } else {
                            self.eventsOnDate[dateWithoutTime] = [value]
                        }
                    } catch {
                        print("Error retrieving event for user \(error.localizedDescription)")
                    }
                }
                self.calendarView.reloadAllEvents()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ProfileCalendarToSelectedEventSegueIdentifier,
           let destination = segue.destination as? SSEventDetailsViewController {
            let dateWithoutTime = self.removeTimeStamp(fromDate: selectedEventDate!)
            let curEventObj = eventsOnDate[dateWithoutTime]![Int(selectedEventIndex)]
            
            // populate fields of next VC
            destination.event = curEventObj
            destination.documentID = curEventObj.id!
        }
    }
}
