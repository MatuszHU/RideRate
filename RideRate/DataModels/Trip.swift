//
//  Trip.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//
import FirebaseFirestore
struct Trip: Identifiable, Codable{
    @DocumentID var id: String?
    var service_id: String
    var trip_short_name: String
    var bikes_allowed: String?
    var shape_id: String?
    var block_id: String?
    var wheelchair_accessible: String?
    var direction_id: String?
    var route_id: String?
    var trip_headsign: String?
}
