//
//  ProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import Firebase
import FirebaseStorage
import CalendarLib

class ProfileViewController: UIViewController, UIScrollViewDelegate, MGCDayPlannerViewDataSource, MGCDayPlannerViewDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var bioText: UILabel!
    @IBOutlet weak var sportsText: UILabel!
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var heightText: UILabel!
    @IBOutlet weak var locationText: UILabel!
    @IBOutlet weak var calendarView: MGCDayPlannerView!
    
    var logoutSegueIdentifier = "LogoutSegue"
    var LocationDetailsToSelectedEventSegueIdentifier = "LocationDetailsToSelectedEventSegueIdentifier"
    
    var UserObject:User!
    
    var eventsOnDate: [Date: [Event]] = [:] // the events under a certain date key must occur on that date
    var events:[String] = [] // will be set from home VC
    
    var selectedEventDate: Date?
    var selectedEventIndex: UInt = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profilePhoto!.layer.cornerRadius = self.profilePhoto!.frame.size.height / 2
        self.profilePhoto.contentMode = .scaleAspectFill

        calendarView.showsAllDayEvents = false
        calendarView.eventIndicatorDotColor = UIColor(.red)
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.backgroundColor = .white
        calendarView.daySeparatorsColor = .systemGray
        calendarView.timeSeparatorsColor = .systemGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docRef = db.collection("users").document(String(uid))
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.nameText.text = String(describing: document.get("fullName")!)
                self.usernameText.text = String(describing: document.get("username")!)
                self.weightText.text = String(describing: document.get("weight")!) + "lbs"
                let newHeight:String = String(describing: document.get("feet")!) + " ft " + String(describing: document.get("inches")!) + " in"
                self.heightText.text = newHeight
                self.locationText.text = String(describing: document.get("location")!)
                self.sportsText.text = String(describing: document.get("sports")!)
                self.bioText.text = String(describing: document.get("bio")!)
                
                let imageURL = String(describing: document.get("url")!)
                
                let imgRef = storage.reference().child(imageURL)
                self.profilePhoto.sd_setImage(with: imgRef, placeholderImage: UIImage(named: "person.crop.circle"))
            } else {
                print("Document does not exist")
            }
        }
        fetchData()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            performSegue(withIdentifier: logoutSegueIdentifier, sender: self)
        } catch let signOutError {
            print(signOutError.localizedDescription)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == logoutSegueIdentifier {
            guard let vc = segue.destination as? LoginViewController else { return }
        }
        
        if segue.identifier == LocationDetailsToSelectedEventSegueIdentifier,
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
