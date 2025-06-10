//
//  Rating.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 07..
//

import Foundation

struct Rating: Identifiable, Codable {
    var id: String = UUID().uuidString
    var vehicleId: String
    var cleanliness: Int
    var punctuality: Int
    var crowdedness: Int
    var comment: String
    var timestamp: Date
}
