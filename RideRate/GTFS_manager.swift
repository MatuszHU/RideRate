//
//  GTFS_manager.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//

import Foundation
import FirebaseFirestore

class GTFS_manager:ObservableObject {
    @Published var trips: [Trip] = []
    @Published var agencies: [Agency] = []
    
    private var db = Firestore.firestore()

    func fetchAllTrips() {
        db.collection("trips").getDocuments(completion: { snapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self.trips = documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                guard let service_id = data["service_id"] as? String else { return nil }
                let trip_short_name = data["trip_short_name"] as? String
                let bikes_allowed = data["bikes_allowed"] as? String
                let shape_id = data["shape_id"] as? String
                let block_id = data["block_id"] as? String
                let wheelchair_accessible = data["wheelchair_accessible"] as? String
                let direction_id = data["direction_id"] as? String
                let route_id = data["route_id"] as? String
                let trip_id = data["trip_id"] as? String
                let trip_headsign = data["trip_headsign"] as? String
                return Trip(
                    id: id,
                    service_id: service_id,
                    trip_short_name: trip_short_name,
                    bikes_allowed: bikes_allowed,
                    shape_id: shape_id,
                    block_id: block_id,
                    wheelchair_accessible: wheelchair_accessible,
                    direction_id: direction_id,
                    route_id: route_id,
                    trip_id: trip_id,
                    trip_headsign: trip_headsign
                )
            }
        })
    }
    func fetchAllAgencies() {
        db.collection("agency").getDocuments(completion: { snapshot, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.agencies = documents.compactMap { doc in
                let data = doc.data()
                let id = doc.documentID
                guard let agency_id = data["agency_id"] as? String else { return nil }
                let phone = data["agency_phone"] as? String
                let tz = data["agency_timezone"] as? String
                let url = data["agency_url"] as? String
                let fare_url = data["agency_fare_url"] as? String
                let lang = data["agency_lang"] as? String
                let name = data["agency_name"] as? String
                return Agency(
                    phone: phone,
                    tz: tz,
                    url: url,
                    fare_url: fare_url,
                    lang: lang,
                    name: name,
                    id: id,
                    agency_id: agency_id
                )
            }
        })
    }
}

