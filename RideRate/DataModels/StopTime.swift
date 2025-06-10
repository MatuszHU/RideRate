//
//  StopTime.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//

import FirebaseFirestore

struct StopTime: Identifiable, Codable{
    
    @DocumentID var id: String?
    var stop_headsign: String?
    var drop_off_type: String?
    var pickup_type: String?
    var stop_id: String?
    var arrival_time: String?
    var trip_id: String?
    var departure_time: String?
    var stop_sequence: Int?
    
}
