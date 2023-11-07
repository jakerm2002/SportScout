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

}

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var owner: User
    var name: String
    var location: String
    var sport: String
    var startTime: Date
    var endTime: Date
    var description: String
    var participants: [FirebaseFirestore.DocumentReference]?
    
    // get the path of each participant DocumentReference
    var participantPaths: [String]? {
        participants?.compactMap() {
            document -> String in
            return document.path
        }
    }
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var feet: String
    var fullName: String
    var inches: String
    var uid: Date
    var username: Date
    var weight: String
}
