//
//  Stop.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//

import FirebaseFirestore

struct Stop: Identifiable, Codable {
    var parent_station: String?
    var stop_code: String?
    @DocumentID var id: String?
    var stop_desc : String?
    var wheelchair_boarding: String?
    var stop_name: String
    var stop_url: String?
    var stop_lon: Double
    var stop_lat: Double
    var location_type: Int
    var zone_id  : String?
    var stop_id: String?
}
