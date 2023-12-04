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
    var owner: DocumentReference
    var name: String
    var location: DocumentReference // a reference to the location
    var locationName: String        // the name of the location
    var sport: String
    var startTime: Date
    var endTime: Date
    var description: String
    var confirmedParticipants: [FirebaseFirestore.DocumentReference]?
    var invitedParticipants: [FirebaseFirestore.DocumentReference]?
    var requestedParticipants: [FirebaseFirestore.DocumentReference]?
    
    // get the path of each participant DocumentReference
    var confirmedParticipantPaths: [String]? {
        confirmedParticipants?.compactMap() {
            document -> String in
            return document.path
        }
    }
    var invitedParticipantPaths: [String]? {
        invitedParticipants?.compactMap() {
            document -> String in
            return document.path
        }
    }
    var requestedParticipantPaths: [String]? {
        requestedParticipants?.compactMap() {
            document -> String in
            return document.path
        }
    }
}

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var bio: String
    var feet: String
    var fullName: String
    var inches: String
    var location: String
    var sports: String
    var username: String
    var weight: String
    
    // image url, could be nil
    var url: String?
}

struct TimelinePost: Identifiable, Codable {
    @DocumentID var id: String?
    var author: DocumentReference
    @ExplicitNull var mediaType: String?
    @ExplicitNull var mediaPath: String?
    @ExplicitNull var caption: String?
    @ExplicitNull var sport: String?
    
    // auto-filled to current time by Firestore when nil is passed in
    @ServerTimestamp var createdAt: Date?
    
    // these should never be set when creating a TimelinePost:
    var authorAsUserModel: User?
    var authorImageData: Data?
    var mediaImageData: Data?
}
