//
//  Shape.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//

import FirebaseFirestore

struct Shape: Identifiable, Codable{
    
    @DocumentID var id: String?
    var shape_pt_lat: Double
    var shape_pt_lon: Double
    var shape_pt_sequence: Int
    var shape_dist_traveled: String?
}
