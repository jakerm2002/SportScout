//
//  SSModels.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/13/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Location: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var addr_field_1: String
    var city: String
    var state: String
    var zip: String
    var imgPath: String
    var events: [FirebaseFirestore.DocumentReference]?
    
    // get the path of each event DocumentReference
    var eventPaths: [String]? {
        events?.compactMap() {
            document -> String in
            return document.path
        }
    }
    
    // we can use getDocument to access the document referenced by the DocumentReference
    var eventObjects: [Event]? {
        guard let events = events else {
            return nil
        }

        var resultArr: [Event] = []

        for doc in events {
            doc.getDocument(as: Event.self) { result in
                do {
                    let value = try result.get()
                    print("Found event at location \(self.name) with value: \(value).")
                    resultArr.append(value)
                } catch {
                    print("Error retrieving event at location \(self.name): \(error)")
                }
            }
        }

        return resultArr
    }

}

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var location: String
    var sport: String
    var startTime: Date
    var endTime: Date
}
