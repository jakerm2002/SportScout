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
    
    var LocationDetailsToSelectedEventSegueIdentifier = "LocationDetailsToSelectedEventSegueIdentifier"
    
    var UserObject:User!
    
    var eventsOnDate: [Date: [Event]] = [:] // the events under a certain date key must occur on that date
    var events:[String] = [] // will be set from home VC
    
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
        fetchData()
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
        guard UserObject != nil else {
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
        // TODO: perform a segue to the event/game page and send over the data from the selected event.
        performSegue(withIdentifier: LocationDetailsToSelectedEventSegueIdentifier, sender: nil)
    }
    
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection("users").document(String(uid))
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                do {
                    self.UserObject = try document.data(as: User.self)
                    Task {
                        await self.fetchEvents()
                    }
                }
                catch {
                    print("Error retrieving event \(error.localizedDescription)")
                }
            }
    }
    
    @MainActor
    func fetchEvents() async {
        eventsOnDate.removeAll()
        // we can use getDocument to access the document referenced by the DocumentReference
        if UserObject != nil && UserObject.events != nil {
            for docRef in UserObject.events! {
                docRef.getDocument(as: Event.self) { result in
                    do {
                        let value = try result.get()
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
                        print("Error retrieving event for user \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
}
